const express = require('express');
const router = express.Router();
const pool = require('../database'); //base de datos
const {isLoggendIn, isAdminUser} = require('../lib/auth'); //session

//Listar los registros
router.get('/', isLoggendIn, async (req, res) => {
    const inventario = await pool.query("SELECT * FROM `tb_inventario`");
    res.render('inventario/list', {inventario});  
});

//Agregar un nuevo registro
router.post('/add', isLoggendIn, async (req, res) => {
    const { codigo, nombre, marca, descripcion, tipo, 
            precioUnitario, precioPublico, cantidadDisponible} = req.body;
    const newproduct = {    
        codigo, nombre, marca, tipo, precioUnitario, precioPublico, cantidadDisponible,
        descripcion: (descripcion == '') ? null : descripcion
    };
    const result = await pool.query('INSERT INTO tb_inventario SET ?', [newproduct]);
    req.flash('success', 'Producto registrado exitosamente.');    
    res.redirect('/inventario');
});

//Editar registro
router.post('/edit/:id', isLoggendIn, isAdminUser , async (req, res) => {
    const {id} = req.params;
    const { nombre, marca, descripcion, tipo, 
        precioUnitario, precioPublico, cantidadDisponible} = req.body;
    const newproduct = {    
        nombre, marca, tipo, precioUnitario, precioPublico, cantidadDisponible,
        descripcion: (descripcion == '') ? null : descripcion
    };
    await pool.query("UPDATE tb_inventario SET ? WHERE codigo = ?", [newproduct, id]);
    req.flash('success', 'La información del cliente se actualizó exitosamente.');
    res.redirect("/inventario"); 
});

 //Eliminar registro
 router.get('/delete/:id', isLoggendIn, isAdminUser, async (req, res) => {
    const {id} = req.params;
    await pool.query('DELETE FROM tb_inventario WHERE codigo = ?', [id]);
    req.flash('success', 'Producto eliminado exitosamente.');
    res.redirect("/inventario");
});

module.exports = router;