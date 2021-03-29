const express = require('express');
const router = express.Router();
const pool = require('../database');

router.get('/', async (req, res) => {
    const consultas = await pool.query("SELECT `IDConsulta`, CONCAT(nombre," 
    + " IFNULL(CONCAT('(', apodos, ')'), ''), ' | ', dir) AS cliente,`descripcion`, fechaRegistro, fechaProgramada, DATE_FORMAT(`fechaProgramada`,'%Y-%m-%d') as fecha, DATE_FORMAT(`fechaProgramada`,'%h:%i') as hora,"
    + " IFNULL( DATE_FORMAT(`fechaProgramada`,'%W %d/%M/%Y (%h:%i)'), 'Sin programar') AS programada,"
    + " IF(estado = 0, 'Pendiente', 'Realizada') AS estado, `prioridad`, `cuentaTotal`,"
    + " `cuentaPagada`, `recepcionista`, IFNULL(veterinario, 'Sin asignar') AS veterinario" 
    + " FROM `tb_consultas` INNER JOIN tb_clientes ON tb_consultas.IDCliente = tb_clientes.IDCliente" 
    + " ORDER BY prioridad DESC");
    res.render('index', {consultas});
});

module.exports = router;