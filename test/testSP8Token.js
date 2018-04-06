const _ = require('lodash');
const { ethTransaction, ethCall } = require('./helper');

const SP8Token = artifacts.require('./contracts/SP8Token.sol');
contract('SP8Token', async (accounts) => {

	describe('getExchangeRate()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('get exchange rate default', async () => {
			return await getExchangeRateDefaultTest(accounts[0], {
				init,
				expected: 38417
			});
		});
	});

	describe('getExchangeRate()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('get exchange rate', async () => {
			return await getExchangeRateTest(accounts[0], {
				init,
				rate: 9000,
				expected: 9000
			});
		});
	});

	describe('setExchangeRate()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('test change exchange rate with owner', async () => {
			return await setExchangeRateTest(accounts[0], {
				init,
				exchangeRate: 9000,
				from: accounts[0],
				expected: 9000
			});
		});

		it('test change exchange rate without owner', async () => {
			return await setExchangeRateTest(accounts[0], {
				init,
				exchangeRate: 9000,
				from: accounts[1],
				expectThow: true,
				expected: 38417
			});
		});

		it('test change exchange rate with exchange rate = 0', async () => {
			return await setExchangeRateTest(accounts[0], {
				init,
				exchangeRate: 0,
				from: accounts[0],
				expectThow: true,
				expected: 38417
			});
		});
	});

	describe('transfer()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('test transfer token with owner', async () => {
			return await transferTest(accounts[0], {
				init,
				to: accounts[1],
				value: 1000*1e8,
				expected: 1000*1e8
			});
		});
		it('test transfer token with address 0x0', async () => {
			return await transferTest(accounts[0], {
				init,
				to: 0x0,
				value: 1000*1e8,
				expectThow: true,
				expected: 0
			});
		});
		it('test transfer token with token < 0', async () => {
			return await transferTest(accounts[0], {
				init,
				to: accounts[1],
				value: -1,
				expectThow: true,
				expected: 0
			});
		});
	});

	describe('buy()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('test buy tokens = 1 ether', async () => {
			return await buyTest(accounts[0], {
				init,
				from: accounts[1],
				value: 1e18,
				expected: 38417*1e18
			});
		});

		it('test buy tokens with address 0x0', async () => {
			return await buyTest(accounts[0], {
				init,
				from: 0x0,
				value: 1e18,
				expectThow: true,
				expected: 0
			});
		});

		it('test buy tokens with 0 ether', async () => {
			return await buyTest(accounts[0], {
				init,
				from: accounts[1],
				value: 0,
				expectThow: true,
				expected: 0
			});
		});
	});

	describe('getIcoAddress()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('test get ico address with owner', async () => {
			return await getIcoAddressTest(accounts[0], {
				init,
				from: accounts[0],
				expected: 0x0dcd2f752394c41875e259e00bb44fd505297caf
			});
		});

		it('test get ico address without owner', async () => {
			return await getIcoAddressTest(accounts[0], {
				init,
				from: accounts[1],
				expected: 0x0000000000000000000000000000000000000000
			});
		});
	});

	describe('setIcoAddress()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('test set ico address correct', async () => {
			return await setIcoAddressTest(accounts[0], {
				init,
				from: accounts[0],
				icoAddress: 0x0dcd2f752394c41875e259e00bb44fd505297caf,
				expected: 0x0dcd2f752394c41875e259e00bb44fd505297caf
			});
		});

		it('test set ico address 0x0', async () => {
			return await setIcoAddressTest(accounts[0], {
				init,
				from: accounts[0],
				icoAddress: 0x0,
				expectThow: true,
				expected: 0x0000000000000000000000000000000000000000
			});
		});

		it('test set ico address without owner', async () => {
			return await setIcoAddressTest(accounts[0], {
				init,
				from: accounts[1],
				icoAddress: 0x0dcd2f752394c41875e259e00bb44fd505297caf,
				expectThow: true,
				expected: 0x0000000000000000000000000000000000000000
			});
		});
	});

	describe('vouchers2Tokens()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('test refund voucher with owner', async () => {
			return await vouchers2TokensTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				recipient: accounts[1],
				value: 100*1e8,
				from: accounts[0],
				expected: 1000*1e8
			});
		});

		it('test refund voucher without owner', async () => {
			return await vouchers2TokensTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				recipient: accounts[1],
				value: 100*1e8,
				from: accounts[1],
				expectThow: true,
				expected: 900*1e8
			});
		});

		it('test refund voucher with address receive 0x0', async () => {
			return await vouchers2TokensTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				recipient: 0x0,
				value: 100*1e8,
				from: accounts[0],
				expectThow: true,
				expected: 900*1e8
			});
		});

		it('test refund voucher with token equal 0', async () => {
			return await vouchers2TokensTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				recipient: accounts[1],
				value: 0,
				from: accounts[0],
				expectThow: true,
				expected: 900*1e8
			});
		});
	});

	describe('tokens2Vouchers()', async () => {
		const init = { totalSupply: 30000000000, name: 'SPXTROS', symbol:'SP8' };
		it('test pay token to address with owner', async () => {
			return await tokens2VouchersTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				message: 0x71d5dc40319194ac8d93750d72a2973977afbf981ce5069f69cede50a1aa406c,
				r: 0xc60e08c4a1b36ba5a57a7d72ca5374a71eb2c3e697154c9b2333da13baca94e41a,
				s: 0xde1eda60c9aa099e1230a5cfe178debde3eb31d0fca4521b9a7807d38ff9051b,
				v: 27,
				value: 100*1e8,
				from: accounts[0],
				expectThow: true,
				expected: 900*1e8
			});
		});

		it('test pay token to address with empty hash', async () => {
			return await tokens2VouchersTest(accounts[0], {
				init,
				hash: '',
				message: 0x71d5dc40319194ac8d93750d72a2973977afbf981ce5069f69cede50a1aa406c,
				r: 0xc60e08c4a1b36ba5a57a7d72ca5374a71eb2c3e697154c9b2333da13baca94e41a,
				s: 0xde1eda60c9aa099e1230a5cfe178debde3eb31d0fca4521b9a7807d38ff9051b,
				v: 27,
				value: 100*1e8,
				from: accounts[0],
				expectThow: true,
				expected: 1000*1e8
			});
		});

		it('test pay token to address with message 0x0', async () => {
			return await tokens2VouchersTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				message: 0x0,
				r: 0xc60e08c4a1b36ba5a57a7d72ca5374a71eb2c3e697154c9b2333da13baca94e41a,
				s: 0xde1eda60c9aa099e1230a5cfe178debde3eb31d0fca4521b9a7807d38ff9051b,
				v: 27,
				value: 100*1e8,
				from: accounts[0],
				expectThow: true,
				expected: 1000*1e8
			});
		});

		it('test pay token to address with incorrect signatures', async () => {
			return await tokens2VouchersTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				message: 0x0,
				r: 0xc60e08c4a1b36ba5a57a7d72ca5374a71eb2c3e697154c9b2333da13baca94e401,
				s: 0xde1eda60c9aa099e1230a5cfe178debde3eb31d0fca4521b9a7807d38ff9051b,
				v: 27,
				value: 100*1e8,
				from: accounts[0],
				expectThow: true,
				expected: 1000*1e8
			});
		});

		it('test pay token to address with value is zero', async () => {
			return await tokens2VouchersTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				message: 0x71d5dc40319194ac8d93750d72a2973977afbf981ce5069f69cede50a1aa406c,
				r: 0xc60e08c4a1b36ba5a57a7d72ca5374a71eb2c3e697154c9b2333da13baca94e41a,
				s: 0xde1eda60c9aa099e1230a5cfe178debde3eb31d0fca4521b9a7807d38ff9051b,
				v: 27,
				value: 0,
				from: accounts[0],
				expectThow: true,
				expected: 1000*1e8
			});
		});

		it('test pay token to address without owner', async () => {
			return await tokens2VouchersTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				message: 0x71d5dc40319194ac8d93750d72a2973977afbf981ce5069f69cede50a1aa406c,
				r: 0xc60e08c4a1b36ba5a57a7d72ca5374a71eb2c3e697154c9b2333da13baca94e41a,
				s: 0xde1eda60c9aa099e1230a5cfe178debde3eb31d0fca4521b9a7807d38ff9051b,
				v: 27,
				value: 100*1e8,
				from: accounts[1],
				expectThow: true,
				expected: 1000*1e8
			});
		});

		it('test pay token to address with exists hash', async () => {
			return await tokens2VouchersExistsHashTest(accounts[0], {
				init,
				hash: '0x0dcd2f752394c41875e259e00bb44fd505297caf',
				message: 0x71d5dc40319194ac8d93750d72a2973977afbf981ce5069f69cede50a1aa406c,
				r: 0xc60e08c4a1b36ba5a57a7d72ca5374a71eb2c3e697154c9b2333da13baca94e41a,
				s: 0xde1eda60c9aa099e1230a5cfe178debde3eb31d0fca4521b9a7807d38ff9051b,
				v: 27,
				from: accounts[0],
				expectThow: true,
				expected: 1000*1e8
			});
		});
	});
});

async function tokens2VouchersExistsHashTest(account, params) {
	const {init, hash, message, r, s, v, value, from, expectThow, expected} = params;
	const tp = await tokenTP(init, account);
	const transfer = await ethTransaction(tp.transfer(from, 1000*1e8));
	const tx = await ethTransaction(tp.tokens2Vouchers(hash, message, r, s, v, value, {from: from}));
	const tx1 = await ethTransaction(tp.tokens2Vouchers(hash, message, r, s, v, value, {from: from}));
	if (expectThow != undefined) {
		tx1.assertThrewError();
	}
	const call = await ethCall(tp.balanceOf.call(from));
	assert.equal(call.returnValue.toNumber(), expected, 'New balance of address ' +from+ ' should be' + expected);
}

async function tokens2VouchersTest(account, params) {
	const {init, hash, message, r, s, v, value, from, expectThow, expected} = params;
	const tp = await tokenTP(init, account);
	const transfer = await ethTransaction(tp.transfer(from, 1000*1e8));
	const tx = await ethTransaction(tp.tokens2Vouchers(hash, message, r, s, v, value, {from: from}));
	if (expectThow != undefined) {
		tx.assertThrewError();
	}
	const call = await ethCall(tp.balanceOf.call(from));
	assert.equal(call.returnValue.toNumber(), expected, 'New balance of address ' +from+ ' should be' + expected);
}

async function vouchers2TokensTest(account, params) {
	const {init, hash, recipient, value, expectThow, from, expected} = params;
	const tp = await tokenTP(init, account);
	const transfer = await ethTransaction(tp.transfer(from, 1000*1e8));
	const buyVoucher = await ethTransaction(tp.tokens2Vouchers(
		'0x0dcd2f752394c41875e259e00bb44fd505297caf', 
		0x71d5dc40319194ac8d93750d72a2973977afbf981ce5069f69cede50a1aa406c, 
		0xc60e08c4a1b36ba5a57a7d72ca5374a71eb2c3e697154c9b2333da13baca94e41a, 
		0xde1eda60c9aa099e1230a5cfe178debde3eb31d0fca4521b9a7807d38ff9051b, 
		27, 
		100*1e8, 
		{from: account}));
	const tx = await ethTransaction(tp.vouchers2Tokens(hash, recipient, value, {from: from}));
	if (expectThow != undefined) {
		tx.assertThrewError();
	}
	const call = await ethCall(tp.balanceOf.call(from));
	assert.equal(call.returnValue.toNumber(), expected, 'New balance of address ' +from+ ' should be' + expected);
}

async function setIcoAddressTest(account, params) {
	const {init, from, icoAddress, expectThow, expected} = params;
	const tp = await tokenTP(init, account);
	const tx = await ethTransaction(tp.setIcoAddress(icoAddress, {from: from}));
	if (expectThow != undefined) {
		tx.assertThrewError();
	}
	const call = await ethCall(tp.getIcoAddress.call());
	assert.equal(call.returnValue.toString(), expected, 'Ico address should be ' + expected);
}

async function getIcoAddressTest(account, params) {
	const {init, from, expected} = params;
	const tp = await tokenTP(init, account);
	const tx = await ethTransaction(tp.setIcoAddress('0x0dcd2f752394c41875e259e00bb44fd505297caf', {from: account}));
	const call = await ethCall(tp.getIcoAddress({from: from}));
	assert.equal(call.returnValue.toString(), expected, 'First ico address should be ', + expected);
}

async function buyTest(account, params) {
	const {init, from, value, expectThow, expected} = params;
	const tp = await tokenTP(init, account);
	const tx = await ethTransaction(tp.buy({from: from, value: value}));
	if (expectThow != undefined) {
		tx.assertThrewError();
	}
	const balanceOf = await ethCall(tp.balanceOf.call(from));
	assert.equal(balanceOf.returnValue.toNumber(), expected, 'Token of '+from+' should be ' + expected);
}

async function transferTest(account, params) {
	const {init, to, value, expectThow, expected} = params;
	const tp = await tokenTP(init, account);
	const tx = await ethTransaction(tp.transfer(to, value));
	if (expectThow != undefined) {
		tx.assertThrewError();
	}
	const balanceOfAddress = await ethCall(tp.balanceOf.call(to));
	assert.equal(balanceOfAddress.returnValue.toNumber(), expected, 'Token of '+to+' should be ' + expected);
}

async function setExchangeRateTest(account, params) {
	const {init, exchangeRate, expectThow, expected, from} = params;
	const tp = await tokenTP(init, account);
	const tx = await ethTransaction(tp.setExchangeRate(exchangeRate, {from: from}));
	if (expectThow != undefined) {
		tx.assertThrewError();
	}
	const rate = await ethCall(tp.exchangeRate.call());
	assert.equal(rate.returnValue.toNumber(), expected, 'Exchange rate should be ' + expected);
}

async function getExchangeRateTest(account, params) {
	const { init, rate, expected } = params;
	const tp = await tokenTP(init, account);
	const setRate = await ethTransaction(tp.setExchangeRate(rate, {from: account}));
	const rate1 = await ethCall(tp.getExchangeRate.call());
	assert.equal(rate1.returnValue.toNumber(), expected, 'First exchange rate should be ' + expected);
}

async function getExchangeRateDefaultTest(account, params) {
	const { init, expected } = params;
	const tp = await tokenTP(init, account);
	const rate = await ethCall(tp.getExchangeRate.call());
	assert.equal(rate.returnValue.toNumber(), expected, 'First exchange rate should be ' + expected);
}

async function balanceOf (tp, address) {
  const b = await tp.balanceOf.call(address)
  return b.toNumber()
}

async function tokenTP (params, account) {
  const { totalSupply, name, symbol } = params
  return await SP8Token.new(
    totalSupply,
    name,
    symbol,
    {
    	from: account
    }
  )
}

