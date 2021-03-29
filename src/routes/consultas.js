const express = require('express');
const router = express.Router();
const pool = require('../database'); //base de datos
const {isLoggendIn, isAdminUser} = require('../lib/auth'); //session

//Agregar una nueva consulta
router.post('/add', isLoggendIn, async (req, res) => {
    const {IDCliente, descripcion, fecha, hora, prioridad, opc} = req.body;
    const newconsulta = {
        IDCliente, descripcion, prioridad,
        fechaProgramada: (opc == 'si') ? (fecha +" "+ hora) : null,
        estado : "0",
        cuentaTotal: "0",
        cuentaPagada: "0",
        recepcionista: req.user.user
    };
    const result = await pool.query('INSERT INTO tb_consultas SET ?', [newconsulta]);
    req.flash('success', 'Consulta registrada exitosamente.');
    res.redirect('/consultas');
});

//Mostrar datos de la tabla
router.get('/', isLoggendIn, async (req, res) => {
    await pool.query("SET lc_time_names = 'es_MX'");
    const consultas = await pool.query("SELECT `IDConsulta`, CONCAT(nombre," 
    + " IFNULL(CONCAT('(', apodos, ')'), ''), ' | ', dir) AS cliente,`descripcion`, fechaRegistro, fechaProgramada, DATE_FORMAT(`fechaProgramada`,'%Y-%m-%d') as fecha, DATE_FORMAT(`fechaProgramada`,'%h:%i') as hora,"
    + " IFNULL( DATE_FORMAT(`fechaProgramada`,'%W %d/%M/%Y (%h:%i)'), 'Sin programar') AS programada,"
    + " IF(estado = 0, 'Pendiente', 'Realizada') AS estado, `prioridad`, `cuentaTotal`,"
    + " `cuentaPagada`, `recepcionista`, IFNULL(veterinario, 'Sin asignar') AS veterinario" 
    + " FROM `tb_consultas` INNER JOIN tb_clientes ON tb_consultas.IDCliente = tb_clientes.IDCliente" 
    + " WHERE estado = 0 ORDER BY fechaRegistro DESC");

    const clientes = await pool.query("SELECT IDCliente, nombre, apodos, dir,"
    +" referencias, telefono,"
    +" CONCAT(nombre, '(', IFNULL(apodos, 'Sin apdos'), ')') AS nombreCompleto"
    +" FROM tb_clientes");

    const direcciones = await pool.query("SELECT * FROM tb_direcciones");
    res.render('consultas/list', {consultas, clientes, direcciones});  
});

//editar consulta
 router.post('/edit/:id', isLoggendIn, isAdminUser, async (req, res) => {
    const {id} = req.params;
    const {descripcion, fecha, hora, prioridad, opc} = req.body;
    const newconsulta = {
        descripcion, prioridad,
        fechaProgramada: (opc == 'si') ? (fecha +" "+ hora) : null,
    };
    await pool.query('UPDATE tb_consultas SET ? WHERE IDConsulta = ?', [newconsulta, id]);
    req.flash('success', 'Consulta actualizada exitosamente.');
    res.redirect("/consultas");
});

//Finalizar consulta
router.get('/end/:id', isLoggendIn, isAdminUser,async (req, res) => {
    const {id} = req.params;
    await pool.query('UPDATE tb_consultas SET estado = 1 WHERE IDConsulta = ?', [id]);
    req.flash('success', 'Consulta finalizada exitosamente.');
    res.redirect("/consultas");
});


//Eliminar consulta
router.get('/delete/:id', isLoggendIn, isAdminUser,async (req, res) => {
    const {id} = req.params;
    await pool.query('DELETE FROM tb_consultas WHERE IDConsulta = ?', [id]);
    req.flash('success', 'Consulta eliminada exitosamente.');
    res.redirect("/consultas");
});

/** ----- TRATAMIENTOS ----- **/
router.get('/:id/tratamiento', isLoggendIn, async (req, res) => {
    const {id} = req.params;
    await pool.query("SET lc_time_names = 'es_MX'");
    const consultas = await pool.query("SELECT `IDConsulta`, CONCAT(nombre," 
    + " IFNULL(CONCAT('(', apodos, ')'), ''), ' | ', dir) AS cliente,`descripcion`, fechaRegistro, fechaProgramada, DATE_FORMAT(`fechaProgramada`,'%Y-%m-%d') as fecha, DATE_FORMAT(`fechaProgramada`,'%h:%i') as hora,"
    + " IFNULL( DATE_FORMAT(`fechaProgramada`,'%W %d/%M/%Y (%h:%i)'), 'Sin programar') AS programada,"
    + " IF(estado = 0, 'Pendiente', 'Realizada') AS estado, `prioridad`, `cuentaTotal`,"
    + " `cuentaPagada`, `recepcionista`, IFNULL(veterinario, 'Sin asignar') AS veterinario" 
    + " FROM `tb_consultas` INNER JOIN tb_clientes ON tb_consultas.IDCliente = tb_clientes.IDCliente" 
    + " WHERE IDConsulta = ? ORDER BY fechaRegistro DESC", [id]);
    const veterinarios = await pool.query("SELECT * FROM tb_empleados WHERE tipo = 'VETERINARIO' ");
    const tratamientos = await pool.query("SELECT IDTratamiento, IDConsulta, descripcion, fechaRealizado,"
    + "precio, veterinario, DATE_FORMAT(`fechaRealizado`,'%W %d/%M/%Y (%h: %i)') as fecha FROM tb_tratamientos WHERE IDConsulta = ?", [id]);
    console.log({consulta: consultas[0], tratamientos});
    res.render('consultas/tratamiento', {consulta: consultas[0], tratamientos, veterinarios});
});

router.post('/:id/tratamiento/add', isLoggendIn, async (req, res) => {
    const {id} = req.params;
    const {descripcion, precio, veterinario} = req.body;
    const tratamiento = {descripcion, precio, veterinario}
    await pool.query("INSERT INTO tb_tratamientos SET IDConsulta = ?, ?", [id, tratamiento]);
    req.flash('success', 'Tratamiento registrado exitosamente.');
    res.redirect('/consultas/'+id+'/tratamiento');
});

router.post('/:idconsulta/tratamiento/edit/:idtratamiento', isLoggendIn, isAdminUser, async (req, res) => {
    const {idconsulta, idtratamiento} = req.params;
    const {descripcion, precio, veterinario} = req.body;
    const tratamiento = {descripcion, precio, veterinario}
    await pool.query('UPDATE tb_tratamientos SET ? WHERE IDConsulta = ? AND IDTratamiento = ?', [tratamiento, idconsulta, idtratamiento]);
    req.flash('success', 'Tratamiento registrado exitosamente.');
    res.redirect('/consultas/'+idconsulta+'/tratamiento/');
});

router.get('/:idconsulta/tratamiento/delete/:idtratamiento', isLoggendIn, isAdminUser, async (req, res) => {
    const {idconsulta, idtratamiento} = req.params;
    await pool.query('DELETE FROM tb_tratamientos WHERE IDConsulta = ? AND IDTratamiento = ?', [idconsulta, idtratamiento]);
    req.flash('success', 'Tratamiento eliminado exitosamente.');
    res.redirect('/consultas/'+idconsulta+'/tratamiento/');
});

module.exports = router;