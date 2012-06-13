
/*
 * GET home page.
 */

module.exports = function (bgcolor) {
  return function(req, res){
    console.log("route: " + bgcolor);
    res.render('index', { title: 'Express' });
  };
}