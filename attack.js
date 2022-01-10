var web3 = require("web3");
var util = require('ethereumjs-util');
var key = "0x7aa914528182dba0e8ba209ff499ed442868940acd87115fb7043bc4ffb84998";
var from = "0x4e9321De20d647C5F7E83D3729daaBBE476C0E26";
var to = from;
var value = "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
var fee = "0x0000000000000000000000000000000000000000000000000000000000000001"
var nonce = 0;
var hash = web3.utils.soliditySha3(from, to, value, fee, nonce);
var sign = util.ecsign(util.toBuffer(hash), util.toBuffer(key));
console.log("v: " + sign.v.toString());
console.log("r: 0x" + sign.r.toString("hex"));
console.log("s: 0x" + sign.s.toString("hex"));
