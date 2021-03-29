const express = require('express');
const router = express.Router();

/* const pool = require('../database'); //base de datos

const {isLoggendIn} = require('../lib/auth');

//Agregar nuevo link
router.get('/add', (req, res) => {
    res.render('links/add');
});

//Ejecutar consulta
router.post('/add', isLoggendIn, async (req, res) => {
    const {title, url, description} = req.body;
    const newlink = {
        title,
        url,
        description,
        user_id: req.user.id
    };
    await pool.query('INSERT INTO links SET ?', [newlink]);
    req.flash('success', 'Link saved successfully');    
    res.redirect('/links'); 
});

//Mostrar datos de la tabla link
router.get('/', isLoggendIn, async (req, res) => {
    const links = await pool.query('SELECT * FROM links WHERE user_id = ?', [req.user.id]);
    res.render('links/list', {links});  
});

//Eliminar links
router.get('/delete/:id', isLoggendIn, async (req, res) => {
    const {id} = req.params;
    await pool.query('DELETE FROM links WHERE ID = ?', [id]);
    req.flash('success', 'Link deleted successfully');
    res.redirect("/links");
});

//Editar registro
router.get('/edit/:id', isLoggendIn, async (req, res) => {
    const {id} = req.params;
    const links = await pool.query("SELECT * FROM links WHERE id = ?", [id]);
    console.log(links[0]);
    res.render("links/edit", {link: links[0]});
});

router.post('/edit/:id', isLoggendIn, async (req, res) => {
    const {id} = req.params;
    const {title, url, description} = req.body;
    const newlink = {
        title,
        description,
        url,
    };
    console.log(newlink);
    await pool.query("UPDATE links SET ? WHERE id = ?", [newlink, id]);
    req.flash('success', 'Link updated successfully');
    res.redirect("/links");
});
 */
module.exports = router;