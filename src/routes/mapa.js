const express = require('express');
const router = express.Router();
const pool = require('../database'); //base de datos
const {isLoggendIn} = require('../lib/auth'); //session

//Listar los registros
router.get('/', isLoggendIn, async (req, res) => {
    var f = new Date();
    f.setUTCHours(6);
    var current_date = f.getFullYear() + "-" + (f.getMonth() +1) + "-" +  f.getDate()+ '%';
    const consultas = await pool.query("SELECT `IDConsulta`, CONCAT(nombre," 
    + " IFNULL(CONCAT('(', apodos,')'),'')) AS cliente, dir,`descripcion`, fechaRegistro,"
    + " IFNULL( DATE_FORMAT(`fechaProgramada`,'%W %d/%M/%Y'), 'Sin programar') AS fechaProgramada,"
    + " IF(estado = 0, 'Pendiente', 'Realizada') AS estado, `prioridad`, `cuentaTotal`,"
    + " `cuentaPagada`, `recepcionista`, IFNULL(veterinario, 'Sin asignar') AS veterinario, lat, lng" 
    + " FROM `tb_consultas` INNER JOIN tb_clientes ON tb_consultas.IDCliente = tb_clientes.IDCliente" 
    + " ORDER BY prioridad DESC", [current_date]);
    res.render('mapa/mapa', {consultas} );  
});

module.exports = router;
