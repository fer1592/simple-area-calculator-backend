var express = require('express');
var app = express();
const { query, validationResult } = require('express-validator');

app.post('/triangle-area', 
  query('base').exists().bail().notEmpty().bail().isFloat({ min: 0 }),
  query('height').exists().bail().notEmpty().bail().isFloat({ min: 0 }),
  function (req, res) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    const base = parseFloat(req.query.base,10);
    const height = parseFloat(req.query.height,10);

    var area = base * height / 2

    console.log(area);

    if(area===Infinity){
      res.status(400).send({
        'errors': [{
          'base': req.query.base,
          'height': req.query.height,
          'msg': 'base or height are too large, and area can\'t be calculated'
        }]
      });
    } else{
      res.send({
        'area': area
      });
    };
  }
);

module.exports = app;