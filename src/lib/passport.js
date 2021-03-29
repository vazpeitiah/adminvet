/**
 * AUTENTICACION DE LOS USUARIOS
 **/

const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const helpers = require('../lib/helpers');
const pool = require('../database');

passport.use('local.signin', new LocalStrategy({
    usernameField: 'user',
    passwordField: 'password',
    passReqToCallback: true 
}, async (req, user, password, done) => {
    const rows = await pool.query('SELECT * FROM tb_empleados WHERE user = ?', [user]);
    if(rows.length > 0){
        const user = rows[0];
        const validPassword = await helpers.matchPassword(password, user.password);
        if(validPassword){
            done(null, user);
        }else{
            done(null, false, req.flash('message', 'Contraseña Incorrecta'));
        }
    }else{
        return done(null, false, req.flash('message', 'Usuario no existente'));
    }
}));

passport.use('local.signup', new LocalStrategy({
    usernameField: 'user',
    passwordField: 'password',
    passReqToCallback: 'true'
}, async (req, user, password, done) => {
    const rows = await pool.query('SELECT * FROM tb_empleados WHERE user = ?', [user]);
    if(rows.length == 0){
        const {nombre} = req.body;
        const newUser = {
            user, //username : username
            password,
            nombre,
            tipo: 'CLIENTE'
        };
        newUser.password = await helpers.encryptPassword(password);
        const result = await pool.query('INSERT INTO tb_empleados SET ?', [newUser]);
        return done(null, newUser);
    } else {
        return done(null, false, req.flash('message', 'El nombre de usuario ya existe. Elige uno nuevo'));
    }
}));

passport.serializeUser((usr, done) => {
    done(null, usr.user);
});

passport.deserializeUser(async (user, done) => {
    const rows = await pool.query('SELECT * FROM tb_empleados WHERE user = ?', [user]);
    done(null, rows[0]);
});

