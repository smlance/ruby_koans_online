var assert = require('assert'),
    vows = require('vows'),
    zombie = require('zombie');

var koansWithAnswers = {
  // "about_asserts": ["true", "true", "2", "2", "2"],
  // "about_nil": ["true", "NoMethodError", "undefined method", "true", "\"\"", "\"nil\""],
  // "about_objects": ["true", "true", "true", "true", "true", "\"123\"", "\"\"", "\"123\"", "\"nil\"", "Fixnum", "true", "0", "2", "4", "1", "3", "5", "201", "true", "true"],
  // "about_arrays": ["Array", "0", "2", "[1, 2, 333]", ":peanut", ":peanut", ":jelly", ":jelly", ":jelly", ":butter", "[:peanut]", "[:peanut, :butter]", "[:and, :jelly]", "[:and, :jelly]", "[]", "[]", "nil", "Range", "[1,2,3,4,5]", "[1,2,3,4]", "[:peanut, :butter, :and]", "[:peanut, :butter]", "[:and, :jelly]", "[1, 2, :last]", ":last", "[1, 2]", "[:first, 1, 2]", ":first", "[1, 2]"],
  // "about_array_assignment": ["[\"John\", \"Smith\"]", "\"John\"", "\"Smith\"", "\"John\"", "\"Smith\"", "\"John\"", "[\"Smith\",\"III\"]", "\"Cher\"", "nil", "[\"Willie\", \"Rae\"]", "\"Johnson\"", "\"John\"", "'Rob'", "'Roy'"],
  // "about_hashes": ["Hash", "0", "2", "\"uno\"", "\"dos\"", "nil", "\"eins\"", "true", "true", "2", "true", "true", "Array", "2", "true", "true", "Array", "true", "54", "26", "true"],
  // "about_strings": ["true", "true", "'He said, \"Go Away.\"'", "\"Don't\"", "true", "true", "true", "54", "53", "\"Hello, World\"", "\"Hello, \"", "\"World\"", "\"Hello, World\"", "\"Hello, \"", "\"Hello, World\"", "\"World\"", "\"Hello, World\"", "1", "2", "2", "\"\\\\'\"", "\"The value is 123\"", "'The value is \#{value}'", "\"The square root of 5 is 2.23606797749979\"", "\"let\"", "\"let\"", "97", "97", "true", "true", "\"Sausage\"", "\"Egg\"", "\"Cheese\"", "\"the\"", "\"rain\"", "\"in\"", "\"spain\"", "\"Now is the time\"", "true", "false"],
  // "about_symbols": ["true", "true", "false", "true", "true", "true", ":catsAndDogs", "\"cats and dogs\"", "\"cats and dogs\"", "'It is raining cats and dogs.'", "false", "false", "false", "false", "NoMethodError", ":catsdogs"],
  // "about_regular_expressions": ["Regexp", "\"match\"", "nil", "\"ab\"", "\"a\"", "\"bccc\"", "\"abb\"", "\"a\"", "\"\"", "\"a\"", "[\"cat\", \"bat\", \"rat\"]", "\"42\"", "\"42\"", "\"42\"", "\" \\t\\n\"", "\"variable_1\"", "\"variable_1\"", "\"abc\"", "\"the number is \"", "\"the number is \"", "\"space:\"", "\" = \"", "\"start\"", "nil", "\"end\"", "nil", "\"2\"", "\"42\"", "\"vines\"", "\"hahaha\"", "\"Gray\"", "\"James\"", "\"Gray, James\"", "\"Gray\"", "\"James\"", "\"James Gray\"", "\"Summer\"", "nil", "[\"one\", \"two\", \"three\"]", "\"one t-three\"", "\"one t-t\""],
  // "about_methods": ["5", "5", "ArgumentError", "wrong number of arguments", "ArgumentError", "wrong number of arguments", ":default_value", "2", "[]", "[:one]", "[:one, :two]", ":return_value", ":return_value", "12", "12", "\"a secret\"", "NoMethodError", "private method `my_private_method' called ", "\"Fido\"", "NoMethodError"],
  // "about_constants": ["\"nested\"", "\"top level\"", "\"nested\"", "\"nested\"", "4", "4", "2", "4"],
  // "about_control_statements": [":true_value", ":true_value", ":true_value", ":false_value", "nil", ":true_value", ":false_value", ":true_value", ":false_value", ":false_value", "3628800", "3628800", "[1, 3, 5, 7, 9]", "\"FISH\"", "\"AND\"", "\"CHIPS\""],
  // "about_true_and_false": [":true_stuff", ":false_stuff", ":false_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff"],
// "about_triangle_project": [],
  // "about_exceptions": ["RuntimeError", "StandardError", "Exception", "Object", ":exception_handled", "true", "true", "\"Oops\"", ":exception_handled", "\"My Message\"", ":always_run", "MySpecialError"],
// "about_triangle_project_2": [],

  // "about_iteration": ["6", "6", "6", "[11, 12, 13]", "[11, 12, 13]", "[2, 4, 6]", "[2, 4, 6]", "\"Clarence\"", "9", "24", "[11, 12, 13]", "[\"THIS\", \"IS\", \"A\", \"TEST\"]"],
  // "about_blocks": ["3", "3", "\"Jim\"", "[:peanut, :butter, :and, :jelly]", ":with_block", ":no_block", ":modified_in_a_block", "11", "11", "\"JIM\"", "20", "11"],
//http://localhost:4567/?koan=about_sandwich_code&input%5B%5D=4&input%5B%5D=%22test%5Cn%22&input%5B%5D=4&input%5B%5D=%22test%5Cn%22&input%5B%5D=4
// write your own sandwich code
// "about_sandwich_code": ["4", "\"test\\n\"", "4", "\"test\\n\"", "4"],

//"about_scoring_project": [],
// Insecure eval and instance_eval
// "about_classes": ["Dog", "[]", "[\"@name\"]", "NoMethodError", "SyntaxError", "\"Fido\"", "\"Fido\"", "\"Fido\"", "\"Fido\"", "\"Fido\"", "\"Fido\"", "\"Fido\"", "ArgumentError", "true", "@name", "fido", "\"Fido\"", "\"My dog is Fido\"", "\"<Dog named 'Fido'>\"", "\"123\"", "\"[1, 2, 3]\"", "\"STRING\"", "'\"STRING\"'"],

  // "about_open_classes": ["\"WOOF\"", "\"HAPPY\"", "\"WOOF\"", "false", "true"],
// "about_dice_project": [],
  // "about_inheritance": ["true", "true", "\"Chico\"", ":happy", "NoMethodError", "\"yip\"", "\"WOOF\"", "\"WOOF, GROWL\"", "NoMethodError"],
  // "about_modules": ["NoMethodError", "\"WOOF\"", "\"Fido\"", "\"Rover\"", ":in_object"],
// _n_ not implemented
// "about_scope": ["NameError", ":jims_dog", ":joes_dog", "true", "true", "true", "false", "true", "3.1416", "true", "true", "true", "true", "[\"Dog\"]"],
// ___ not implemented? on CAUGHT?.___
  // "about_message_passing": ["\"?\"", "downcase", "true", "true", "false", "[]", "[]", "[3, 4, nil, 6]", "[3, 4, nil, 6]", "NoMethodError", "NoMethodError", "\"Someone called foobar with <>\"", "\"Someone called foobaz with <1>\"", "\"Someone called sum with <1, 2, 3, 4, 5, 6>\"", "false", "\"Foo to you too\"", "\"Foo to you too\"", "NoMethodError", "true", "false"],
  // "about_to_str": ["\"non-string-like\"", "TypeError", "\"string-like\"", "false", "false", "true"],
// "about_extra_credit": [],
}
var buildTestScripts = function(){
  var scripts = {}
  for (var koanName in koansWithAnswers) {
    console.log("***************************************************");
    console.log(koanName);
    if (koansWithAnswers.hasOwnProperty(koanName)) {
      var answers = koansWithAnswers[koanName];
      scripts['visits '+koanName] = {
        topic: function(kn){ return function(){
          var zb = new zombie.Browser({debug: true})
          var url = "http://localhost:4567/?koan="+kn;
     console.log("++++++++++++++++++++++++++++");
     console.log(kn);

          zb.visit(url, this.callback);
        };}(koanName),
        'and enters the correct values': {
          topic: function(koanName, answers){ return function(browser){
            var koanNameElement = browser.querySelector(":input[name=koan]");
            assert.equal(koanNameElement.value, koanName);
            for(var i=0; i<answers.length; i++) browser.fill(":input:eq("+(i+2)+")", answers[i]);

            browser.pressButton(":input[type=submit]", this.callback);
          }; }(koanName, answers),
          'heightens my awareness': function(err, browser, status){
            assert.matches(browser.html(), /has heightened your awareness/);
          }
        }
      };
    }
  }
  console.log(scripts)
  return scripts;
}
vows.describe('Google').addBatch({
  'Given a headless browser': buildTestScripts()
}).run();
