/**
 * FUNCIONES PARA VALIDAR LAS SESSIONES
 **/

module.exports = {
    isLoggendIn(req, res, next) {
        if(req.isAuthenticated()){
            return next();
        }
        return res.redirect('/signin');
    },
    
    isNotLoggedIn(req, res, next){
        if(!req.isAuthenticated()){
            return next();
        }
        return res.redirect('/');
    },
    isAdminUser(req, res, next){
        if(req.user.tipo == 'ADMINISTRADOR'){
            return next();
        }
        req.flash('message', 'Solo los administradores pueden realizar esta acción');
        return res.redirect(req.baseUrl);
    },
}