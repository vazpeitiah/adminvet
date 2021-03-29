const express = require('express');
const router = express.Router();
const pool = require('../database'); //base de datos
const {isLoggendIn, isAdminUser} = require('../lib/auth'); //session
const helpers = require('../lib/helpers'); 

//Listar los registros
router.get('/', isLoggendIn, async (req, res) => {
    const empleados = await pool.query("SELECT * FROM `tb_empleados` WHERE tipo != 'ADMINISTRADOR' AND tipo != 'CLIENTE' ");
    res.render('empleados/list', {empleados});  
});

//Agregar un nuevo registro
router.post('/add', isLoggendIn, isAdminUser, async (req, res) => {
    const {user, password, nombre, tipo, telefono} = req.body;
    const rows = await pool.query('SELECT * FROM tb_empleados WHERE user = ?', [user]);
    if(rows.length == 0){
        const newUser = {    
            user, password, nombre, tipo,
            telefono: (telefono == '') ? null : telefono
        };
        newUser.password = await helpers.encryptPassword(password);
        const result = await pool.query('INSERT INTO tb_empleados SET ?', [newUser]);
        req.flash('success', 'Empleado registrado exitosamente.');    
        
    }else{
        req.flash('message', 'ERROR: El nombre de usuario '+ [user] +' ya ha sido utilizado. Elige uno nuevo.');  
    }
    res.redirect('/empleados');
});

//Editar registro
router.post('/edit/:id', isLoggendIn, isAdminUser, async (req, res) => {
    const {id} = req.params;
    const {password, nombre, tipo, telefono, opc} = req.body;
    const pass = await pool.query('SELECT password FROM tb_empleados WHERE user = ?', [id]);
    const newuser = { nombre, tipo, 
        telefono: (telefono == '') ? null : telefono,
        password: (opc == 'SI') ? await helpers.encryptPassword(password) : pass[0].password
    };
    await pool.query("UPDATE tb_empleados SET ? WHERE user = ?", [newuser, id]);
    req.flash('success', 'La información del empleado se actualizó exitosamente.');
    res.redirect("/empleados"); 
});

 //Eliminar registro
 router.get('/delete/:id', isLoggendIn, isAdminUser, async (req, res) => {
    const {id} = req.params;
    await pool.query('DELETE FROM tb_empleados WHERE user = ?', [id]);
    req.flash('success', 'Empleado eliminado exitosamente.');
    res.redirect("/empleados");
});

module.exports = router;