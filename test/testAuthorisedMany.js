const _ = require('lodash');
const { ethTransaction, ethCall } = require('./helper');
const SP8Token = artifacts.require('./contracts/SP8Token.sol');
const SP8TokenSale = artifacts.require('SP8TokenSale.sol');
var crypto = require('crypto');

contract('SP8TokenSale', async (accounts) => {
	describe('authoriseManyAccounts()', async () => {
		var whoms = [];
		for (var i = 0; i < 100; i++) {
			whoms.push('0x' + crypto.randomBytes(40).toString('hex').substr(0, 40));
		}
		it('test authorised 10000 accounts with owner', async () => {
			console.log(whoms);
			return await authoriseManyAccountsTest(accounts[0], {
				cs: accounts[1],
				whoms: whoms,
				from: accounts[0],
				expected: true
			});
		});
	});
});

async function authoriseManyAccountsTest(account, params) {
	const {cs, whoms, from, expected, expectThrow} = params;
	const tp = await tokenTP(account);
	const setCS = await ethTransaction(tp.setCS(cs, {from: account}));
	const tx = await ethTransaction(tp.authoriseManyAccounts(whoms, {from: from}));
	if (expectThrow != undefined) {
		tx.assertThrewError();
	}
	console.log(tx);
	// const auth = true;
	// whoms.forEach(async (whom) => {
	// 	const authorised = await ethCall(tp.getAuth(whom));
	// 	if (!authorised.returnValue) {
	// 		auth = false;
	// 		break;
	// 	}
	// });
	// assert.equal(auth, expected, 'many account should be allow');
}

async function tokenTP (account) {
	const token = await SP8Token.new(30000000000, 'SPXTROS', 'SP8', {from: account});
	return await SP8TokenSale.new(
	    token.address,
	    {
	    	from: account
	    }
	);
}