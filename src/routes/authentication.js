const express = require('express');
const router = express.Router();

const passport = require('passport');
const {isLoggendIn, isNotLoggedIn} = require('../lib/auth');

router.get('/signup', isNotLoggedIn, (req, res) => {
    //res.render('auth/signup');
    res.send("Opcion no disponible");
});

router.post('/signup', isNotLoggedIn, passport.authenticate('local.signup', {
    /* successRedirect: '/profile', //Registro correcto
    failureRedirect: '/signup', //Registro incorrecto
    failureFlash: true //Permite mensajes flash */
}));

router.get('/signin', isNotLoggedIn, (req, res) => {
    res.render('auth/signin');
});

router.post('/signin', isNotLoggedIn, (req, res, next) => {
    passport.authenticate('local.signin', {
        successRedirect: '/', //Inicio de sesión éxitoso
        failureRedirect: '/signin', //Usuario y/o contraseñas incorrectas
        failureFlash: true,
    }) (req, res, next);
});

router.get('/profile', isLoggendIn,(req, res) => {
    res.render('profile');
});

router.get('/logout', isLoggendIn, (req, res) => {
    req.logOut();
    res.redirect('/signin');
});

module.exports = router;