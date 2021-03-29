/**
 * FUNCIONES AUXILIARES GLOBALES PARA HANDLEBARS
 **/

const {format, register} = require('timeago.js'); //importamos los metodos format y register
const Handlebars = require('handlebars');



const localeFunc = (number, index, totalSec) => { //Nuestra configuracion en español
    return [
        ['justo ahora', 'en un rato'],
        ['hace %s segundos', 'en %s segundos'],
        ['hace 1 minuto', 'en 1 minuto'],
        ['hace %s minutos', 'en %s minutos'],
        ['hace 1 hora', 'en 1 hora'],
        ['hace %s horas', 'en %s horas'],
        ['hace 1 día', 'en 1 día'],
        ['hace %s días', 'en %s días'],
        ['hace 1 semana', 'en 1 semana'],
        ['hace %s semanas', 'en %s semanas'],
        ['hace 1 mes', 'en 1 mes'],
        ['hace %s meses', 'en %s meses'],
        ['hace 1 año', 'en 1 año'],
        ['hace %s años', 'en %s años'],
      ][index];
  };
  // Añadimos nuestra configuracion para que pueda ser utilizada por la funcion format
  register('es', localeFunc);

const helpers =  {}

//Para mostrar cuanto tiempo paso o cuanto tiempo falta
helpers.timeago = (timestamp) => {
    var date = new Date(timestamp);
    var utc = date.getTime() + date.getTimezoneOffset() * 60000; //El UTC es 06:00
    var newDate = new Date(utc + (3600000 * 6)); //Ajustamos el UTC
    return format(newDate, 'es'); //Retornamos la fecha con el UTC corregido con el formato local que registramos
};

helpers.priority  = (prioridad) => {
    switch(prioridad){   
        case 0:
            return new Handlebars.SafeString('<span class="badge badge-pill badge-info">No urgente</span>');
        case 1:
            return new Handlebars.SafeString('<span class="badge badge-pill badge-warning">Urgente</span>');
        case 2:
            return new Handlebars.SafeString('<span class="badge badge-pill badge-danger">Muy urgente</span>');
        default: 
            return new Handlebars.SafeString('<p>Prioridad invalida</p>');
    }
};

helpers.isVeterinarioUser = (tipo) => {
    if(tipo === "VETERINARIO")
        return 1;
    return 0;
};

helpers.isAdminUser = (tipo) => {
    if(tipo === "ADMINISTRADOR")
        return 1;
    return 0;
};

helpers.colorprioridad  = (prioridad) => {
    switch(prioridad){   
        case 0: return 'info';
        case 1: return 'warning';
        case 2: return 'danger';
        default:  return 'light';
    }
};

helpers.current_day = () => {
    var date = new Date();
    var utc = date.getTime() + date.getTimezoneOffset() * 60000; //El UTC es 06:00
    var newDate = new Date(utc + (3600000 * 6)); //Ajustamos el UTC
    var current_date = newDate.getFullYear() + "-" + (newDate.getMonth() +1) + "-" +  newDate.getDate();
    return current_date;
}

helpers.isEmpleado = (tipo) => {
    if(tipo === "CLIENTE")
        return 0;
    return 1;
}

module.exports = helpers; //exportamos todas las funciones de helpers