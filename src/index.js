const express = require('express'); //Framework para el servidor
const morgan = require('morgan'); //Para mostrar las peticiones que se realizen en consola
const exphbs = require('express-handlebars'); //Manejo de vistas con handelbars
const path = require('path'); //Crear rutas
const flash = require('connect-flash'); //Alertas o mensajes
const session = require('express-session'); //Sessiones
const MySQLstore = require('express-mysql-session'); //Guardar las sesiones en la base de datos

const {database} = require('./keys'); //Importamos los parametros para conectar con la base de datos
const passport = require('passport');

//Incializar variables
const app = express(); //Inicializamos express
require('./lib/passport'); //Contiene las rutas de inicio de sesión

//Configuraciones
app.set('port', process.env.PORT || 4000); //Creamos el servicio en el puerto disponible o sino en el puerto 4000
app.set('views', path.join(__dirname, 'views')); //Creamos una nueva ruta para views, concatenando la direccion del proyecro y views
app.engine('.hbs', exphbs({ //Configuarion para usar handlebars
    defaultLayout: 'main',
    layoutsDir: path.join(app.get('views'), 'layouts'),
    partialsDir: path.join(app.get('views'), 'partials'),
    extname: '.hbs', //Indicamos que usaremos esta extensión en lugar de .handlebars
    helpers: require('./lib/handlebars') //Incluimos las funciones helpers a handlebars
}));
app.set('view engine', '.hbs');

//middlewares
app.use(morgan('dev')); //Para mostrar las peticiones en consola
app.use(express.urlencoded({extended: false})); //Para que express acepte peticiones realizadas con formularios HTML
app.use(express.json()); //Para que express reciba y envie obejetos json
app.use(flash()); //Para enviar mensajes
app.use(session({ //sessiones
    secret: "sessioninit",
    resave: false,
    saveUninitialized: false,
    store: new MySQLstore(database) //almacenamos las sesiones en la base de datos
}));
app.use(passport.initialize());
app.use(passport.session());

//variables globales
app.use((req, res, next) =>{
    app.locals.success = req.flash('success');
    app.locals.message = req.flash('message');
    app.locals.user = req.user;
    next();
});

//routes
app.use(require('./routes'));
app.use(require('./routes/authentication'));
app.use('/links', require('./routes/links'));
app.use('/clientes', require('./routes/clientes'));
app.use('/consultas', require('./routes/consultas'));
app.use('/inventario', require('./routes/inventario'));
app.use('/botiquines', require('./routes/botiquines'));
app.use('/empleados', require('./routes/empleados'));
app.use('/mapa', require('./routes/mapa'));
app.use('/mapa_clie', require('./routes/mapa_clie'));


//public
app.use(express.static(path.join(__dirname, 'public')));

//iniciar servidor
app.listen(app.get('port'), () => {
    console.log('server on port', app.get('port'));
});