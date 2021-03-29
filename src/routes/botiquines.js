const express = require('express');
const router = express.Router();
const pool = require('../database'); //base de datos
const {isLoggendIn, isAdminUser} = require('../lib/auth'); //session

//Listar los registros
router.get('/', isLoggendIn, async (req, res) => {
    const botiquines = await pool.query("SELECT * FROM tb_botiquin");
    const veterinarios = await pool.query("SELECT * FROM tb_empleados WHERE tipo = 'VETERINARIO'");
    res.render('botiquines/list', {botiquines, veterinarios});  
});

//Agregar un nuevo registro
router.post('/add', isLoggendIn, isAdminUser, async (req, res) => {
    const {descripcion, veterinario} = req.body;
    const newbotiquin = {descripcion, veterinario: (veterinario == '') ? null : veterinario };
    await pool.query('INSERT INTO tb_botiquin SET ?', [newbotiquin]);
    req.flash('success', 'Botiquin registrado exitosamente.');
    res.redirect(req.baseUrl);
});

//Editar registro
router.post('/edit/:id', isLoggendIn, isAdminUser, async (req, res) => {
    const {id} = req.params;
    const {descripcion, veterinario} = req.body;
    const newbotiquin = {descripcion, veterinario: (veterinario == '') ? null : veterinario };
    await pool.query("UPDATE tb_botiquin SET ? WHERE numero = ?", [newbotiquin, id]);
    req.flash('success', 'La información del botiquin se actualizó exitosamente.');
    res.redirect(req.baseUrl); 
});

 //Eliminar registro
 router.get('/delete/:id', isLoggendIn, isAdminUser, async (req, res) => {
    const {id} = req.params;
    await pool.query('DELETE FROM tb_botiquin WHERE numero = ?', [id]);
    req.flash('success', 'Botiquin eliminado exitosamente.');
    res.redirect(req.baseUrl);
});

router.get('/:id/contenido', isLoggendIn, async (req, res) => {
    const {id} = req.params;
    const botiquines = await pool.query('SELECT * FROM tb_botiquin WHERE numero = ?', [id]);
    const medicamentos = await pool.query("SELECT botiquin, `medicamento`, `cantidad`," 
    + " marca, nombre, descripcion FROM `lista_medicamentos`" 
    + " INNER JOIN tb_inventario ON medicamento = codigo WHERE botiquin = ?", [id]);
    const inventario = await pool.query("SELECT * FROM tb_inventario");
    res.render('botiquines/contenido', {botiquin : botiquines[0], medicamentos, inventario});
});

router.post('/:botiquin/contenido/add', isLoggendIn, async (req, res) => {
    const {botiquin} = req.params;
    const {medicamento, cantidad} = req.body;
    const add = {botiquin, medicamento, cantidad};
    const rows = await pool.query("SELECT * FROM lista_medicamentos WHERE botiquin = ? AND medicamento = ?", [botiquin, medicamento]);
    
    if(rows.length == 0){
        await pool.query('INSERT INTO lista_medicamentos SET ?', [add]);
    }else{
        var newcantidad = parseInt(rows[0].cantidad) + parseInt(add.cantidad);
        await pool.query('UPDATE lista_medicamentos SET cantidad = ?', newcantidad);
    }

    req.flash('success', 'Medicamento agregado exitosamente.');
    res.redirect('/botiquines/'+botiquin+'/contenido');
});

router.get('/:botiquin/contenido/delete/:medicamento', isLoggendIn, async (req, res) => {
    const {botiquin, medicamento} = req.params;
    const result = await pool.query('DELETE FROM lista_medicamentos WHERE botiquin = ? AND medicamento = ?', [botiquin, medicamento]);
    req.flash('success', 'Medicamento agotado exitosamente.');
    res.redirect('/botiquines/'+botiquin+'/contenido');
});

module.exports = router;