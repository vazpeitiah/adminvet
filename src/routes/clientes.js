const express = require('express');
const router = express.Router();
const pool = require('../database'); //base de datos
const {isLoggendIn, isAdminUser} = require('../lib/auth'); //session

//Listar los registros
router.get('/', isLoggendIn, async (req, res) => {
    const clientes = await pool.query("SELECT IDCliente, nombre, apodos,"
    +" referencias, telefono,IFNULL(telefono, 'Sin registrar') AS tel, CONCAT(dir, IFNULL(CONCAT(' (', referencias, ')'), '') ) AS direccionCompleta,"
    +" CONCAT(nombre, IFNULL(CONCAT(' (', apodos, ')'), '') ) AS nombreCompleto, lat, lng, dir"
    +" FROM tb_clientes ORDER BY IDCliente DESC");
    const direcciones = await pool.query("SELECT * FROM tb_direcciones");
    res.render('clientes/list', {clientes, direcciones});  
});

//Agregar un nuevo registro
router.post('/add', isLoggendIn, async (req, res) => {
    const {nombre, apodos, telefono, dir, lat, lng} = req.body;
    const newcliente = {
        nombre, 
        //direccion, referencias: (referencias == '') ? null : referencias,
        apodos: (apodos == '') ? null : apodos,
        dir, lat, lng,
        telefono: (telefono == '') ? null : telefono
    };
    const result = await pool.query('INSERT INTO tb_clientes SET ?', [newcliente]);
    req.flash('success', 'Cliente almacenado correctamente.');    
    res.redirect('/clientes');
});

//Editar registro
router.post('/edit/:id', isLoggendIn, isAdminUser, async (req, res) => {
    const {id} = req.params;
    const {nombre, apodos, telefono} = req.body;
    const newcliente = {
        nombre, 
        //direccion, referencias: (referencias == '') ? null : referencias,
        apodos: (apodos == '') ? null : apodos,        
        telefono: (telefono == '') ? null : telefono
    };
    await pool.query("UPDATE tb_clientes SET ? WHERE IDCliente = ?", [newcliente, id]);
    req.flash('success', 'La información del cliente se actualizó exitosamente.');
    res.redirect("/clientes"); 
});

 //Eliminar registro
 router.get('/delete/:id', isLoggendIn, isAdminUser, async (req, res) => {
    const {id} = req.params;
    await pool.query('DELETE FROM tb_clientes WHERE IDCliente = ?', [id]);
    req.flash('success', 'Cliente eliminado exitosamente.');
    res.redirect("/clientes");
});

router.get('/mark/:id', async (req, res) => {
    const {id} = req.params;
    const clientes = await pool.query('SELECT * FROM tb_clientes WHERE IDCliente = ?', [id]);
    res.render('clientes/mark', {clientes: clientes[0]} );
});

router.post('/mark/:id', isLoggendIn, async (req, res) => {
    const {id} = req.params;
    const {lat, lng, dir} = req.body;
    await pool.query("UPDATE tb_clientes SET lat = ?, lng = ?, dir = ? WHERE IDCliente = ?", [lat, lng, dir, id]);
    req.flash('success', 'Vivienda registrada exitosamente.');
    res.redirect("/clientes"); 
});

module.exports = router;