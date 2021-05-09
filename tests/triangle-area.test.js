//Test to check if the api is returning the right area for a triangle
const request = require('supertest');
const app = require('../app');
describe('triangle-area post endpoint',() => {
  test('should return 4.5 as the area of the triangle', () => {
    return request(app)
      .post('/triangle-area')
      .query({ 
        base: 3,
        height: 3
      })
      .then(response =>{
        expect(response.status).toEqual(200);
        expect(response.body.area).toEqual(4.5);
      });
  });
  test('should return invalid value if base or hight are not numbers', () => {
    return request(app)
      .post('/triangle-area')
      .query({
        base: 'not-a-number',
        height: 'not-a-number'
      })
      .then(response =>{
        expect(response.status).toEqual(400);
        expect(response.body.errors[0].msg).toEqual("Invalid value");
        expect(response.body.errors[1].msg).toEqual("Invalid value");
      });
  });
  test('should return invalid value if base or hight are negative values', () => {
    return request(app)
      .post('/triangle-area')
      .query({
        base: -1,
        height: -0.1
      })
      .then(response =>{
        expect(response.status).toEqual(400);
        expect(response.body.errors[0].msg).toEqual("Invalid value");
        expect(response.body.errors[1].msg).toEqual("Invalid value");
      });
  });
  test('should return error if the result is so large that is Infinity', () => {
    return request(app)
      .post('/triangle-area')
      .query({
        base: 999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999,
        height: 999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
      })
      .then(response =>{
        expect(response.status).toEqual(400);
        expect(response.body.errors[0].msg).toEqual("base or height are too large, and area can\'t be calculated");
      });
  });
})