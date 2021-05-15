//Test to check if the api is returning the right area for a rectangle
const request = require('supertest');
const app = require('../app');
describe('rectangle-area post endpoint',() => {
  test('should return 35.9214 as the area of the rectangle', () => {
    return request(app)
      .post('/rectangle-area')
      .query({ 
        side1: 4.37,
        side2: 8.22
      })
      .then(response =>{
        expect(response.status).toEqual(200);
        expect(response.body.area).toEqual(35.921400000000006);
      });
  });
  test('should return invalid value if any side is not numbers', () => {
    return request(app)
      .post('/rectangle-area')
      .query({
        side1: 'not-a-number',
        side2: 'not-a-number'
      })
      .then(response =>{
        expect(response.status).toEqual(400);
        expect(response.body.errors[0].msg).toEqual("Invalid value");
        expect(response.body.errors[1].msg).toEqual("Invalid value");
      });
  });
  test('should return invalid value if any side is negative values', () => {
    return request(app)
      .post('/rectangle-area')
      .query({
        side1: -1,
        side2: -0.1
      })
      .then(response =>{
        expect(response.status).toEqual(400);
        expect(response.body.errors[0].msg).toEqual("Invalid value");
        expect(response.body.errors[1].msg).toEqual("Invalid value");
      });
  });
  test('should return error if the result is so large that is Infinity', () => {
    return request(app)
      .post('/rectangle-area')
      .query({
        side1: 999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999,
        side2: 999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
      })
      .then(response =>{
        expect(response.status).toEqual(400);
        expect(response.body.errors[0].msg).toEqual("At least one of the sides is too large, and area can\'t be calculated");
      });
  });
})