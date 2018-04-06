const _ = require('lodash');
const { ethTransaction, ethCall } = require('./helper');
const SP8Token = artifacts.require('./contracts/SP8Token.sol');
const SP8TokenSale = artifacts.require('SP8TokenSale.sol');

contract('SP8TokenSale', async (accounts) => {
	describe('hasEnd()', async () => {
		it('test has end', async () => {
			return await hasEndTest(accounts[0]);
		});
	});

	describe('pause()', async () => {
		it('test set pause while pause = false', async () => {
			return await pauseTest(accounts[0], {pause: false, expected: true, from: accounts[0]});
		});

		it('test set pause while pause = true', async () => {
			return await pauseTest(accounts[0], {pause: true, expectThrow: true, from: accounts[0]});
		});

		it('test set pause without owner', async () => {
			return await pauseTest(accounts[0], {pause: false, expectThrow: true, expected: false, from: accounts[1]});
		});
	});

	describe('unpause()', async () => {
		it('test set unpause while pause = false', async () => {
			return await unpauseTest(accounts[0], {pause: false, expectThrow: true, from: accounts[0]});
		});

		it('test set unpause while pause = true', async () => {
			return await unpauseTest(accounts[0], {pause: true, expected: true, expected: false, from: accounts[0]});
		});

		it('test set unpause without owner', async () => {
			return await unpauseTest(accounts[0], {pause: true, expectThrow: true, expected: true, from: accounts[1]});
		});
	});

	describe('buy()', async () => {
		it('test buy ico token in ico pre sale', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: 1e18,
				phase: 1,
				expected: 49942*1e18
			});
		});

		it('test buy ico token in ico public sale', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: 1e18,
				phase: 2,
				expected: 46100*1e18
			});
		});

		it('test buy ico token before ico pre sale', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: 1e8,
				phase: 0,
				expectThrow: true,
				expected: 0
			});
		});

		it('test buy ico token after ico end', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: 1e8,
				phase: 5,
				expectThrow: true,
				expected: 0
			});
		});

		it('test buy ico token when not pause', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: 1e18,
				pause: false,
				phase: 1,
				expected: 49942*1e18
			});
		});

		it('test buy ico token when pause', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: 1e8,
				pause: true,
				phase: 1,
				expectThrow: true,
				expected: 0
			});
		});

		it('test buy ico token quater than tokenPreSale', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: 1e18,
				phase: 1,
				expected: 49942*1e18
			});
		});

		it('test buy ico token greater than tokenPreSale', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: accounts[1].balance,
				phase: 1,
				expected: 0
			});
		});

		it('test buy ico token quater than tokenPublicSale', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: 1e18,
				phase: 2,
				expected: 46100*1e18
			});
		});

		it('test buy ico token greater than tokenPublicSale', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: accounts[1].balance,
				phase: 2,
				expected: 0
			});
		});

		it('test buy ico token with address not authorised', async () => {
			return await buyTest(accounts[0], {
				from: accounts[1],
				value: accounts[1].balance,
				phase: 1,
				unauthorised: true,
				expectThrow: true,
				expected: 0
			});
		});
	});

	describe('payTokensToAddress()', async () => {
		it('test pay token to address with owner', async () => {
			return await payTokensToAddressTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				expected: 0
			});
		});

		it('test pay token to address without owner', async () => {
			return await payTokensToAddressTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[1],
				expectThrow: true,
				expected: 49942*1e18
			});
		});

		it('test pay token to address while ico', async () => {
			return await payTokensToAddressTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				expectThrow: true,
				phase: 1,
				expected: 49942*1e18
			});
		});

		it('test pay token to address after ico', async () => {
			return await payTokensToAddressTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				expected: 0
			});
		});

		it('test pay token to address with address recipient 0x0', async () => {
			return await payTokensToAddressTest(accounts[0], {
				recipient: 0x0,
				from: accounts[0],
				expectThrow: true
			});
		});

		it('test pay token to address with address recipient not exists in ico', async () => {
			return await payTokensToAddressTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				expectThrow: true,
				recipientExists: false
			});
		});

		it('test pay token to address while ico unpause', async () => {
			return await payTokensToAddressTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				pause: false,
				expected: 0
			});
		});

		it('test pay token to address while ico pause', async () => {
			return await payTokensToAddressTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				pause: true,
				expected: 49942*1e18
			});
		});
	});

	describe('reFundETH()', async () => {
		it('test refund eth with owner', async () => {
			return await reFundETHTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				value: 1e18,
				expected: 0
			});
		});

		it('test refund eth without owner', async () => {
			return await reFundETHTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[1],
				value: 1e18,
				expectThrow: true,
				expected: 1e18
			});
		});

		it('test refund eth with address recipient 0x0', async () => {
			return await reFundETHTest(accounts[0], {
				recipient: 0x0,
				from: accounts[0],
				value: 1e18,
				expectThrow: true
			});
		});

		it('test refund eth with address not exists in ico', async () => {
			return await reFundETHTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				value: 1e18,
				expectThrow: true,
				reNotExists: true
			});
		});

		it('test refund eth when not paused', async () => {
			return await reFundETHTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				value: 1e18,
				pause: false,
				expected: 0
			});
		});

		it('test refund eth when paused', async () => {
			return await reFundETHTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				value: 1e18,
				pause: true,
				expectThrow: true,
				expected: 1e18
			});
		});

		it('test refund eth with msg.value <> ether need to send', async () => {
			return await reFundETHTest(accounts[0], {
				recipient: accounts[1],
				from: accounts[0],
				value: 2e18,
				expectThrow: true,
				expected: 1e18
			});
		});
	});

	describe('eth2SPXToken()', async () => {
		it('test convert ether to token while ico pre sale', async () => {
			return await eth2SPXTokenTest(accounts[0], {
				value: 1e18,
				from: accounts[0],
				phase: 1,
				expected: 49942*1e18
			});
		});

		it('test convert ether to token while ico public sale', async () => {
			return await eth2SPXTokenTest(accounts[0], {
				value: 1e18,
				from: accounts[0],
				phase: 2,
				expected: 46100*1e18
			});
		});
	});

	describe('getCurrentICOPhase()', async () => {
		it('test get ico phase one', async () => {
			return await getCurrentICOPhaseTest(accounts[0], {
				phase: 1,
				from: accounts[0]
			});
		});

		it('test get ico phase two', async () => {
			return await getCurrentICOPhaseTest(accounts[0], {
				phase: 2,
				from: accounts[0]
			});
		});

		it('test get ico phase three', async () => {
			return await getCurrentICOPhaseTest(accounts[0], {
				phase: 3,
				from: accounts[0]
			});
		});

		it('test get ico phase four', async () => {
			return await getCurrentICOPhaseTest(accounts[0], {
				phase: 4,
				from: accounts[0]
			});
		});

		it('test get ico phase after ico finish', async () => {
			return await getCurrentICOPhaseTest(accounts[0], {
				phase: 5,
				from: accounts[0]
			});
		});
	});

	describe('calculateTokens()', async () => {
		it('test caculate token while ico pre sale', async () => {
			return calculateTokensTest(accounts[0], {
				phase: 1,
				value: 1e18,
				from: accounts[0],
				expected: 1.3e+36
			});
		});

		it('test caculate token while ico public sale', async () => {
			return calculateTokensTest(accounts[0], {
				phase: 2,
				value: 1e18,
				from: accounts[0],
				expected: 1.2e+36
			});
		});
	});

	describe('getTotalTokenOfAddress()', async () => {
		it('test get total token of address', async () => {
			return await getTotalTokenOfAddressTest(accounts[0], {
				addr: accounts[0],
				from: accounts[0]
			});
		});
	});

	describe('getTotalETHOfAddress()', async () => {
		it('test get total ether of address', async () => {
			return await getTotalETHOfAddressTest(accounts[0], {
				addr: accounts[0],
				from: accounts[0]
			});
		});
	});

	describe('getTokenSold()', async () => {
		it('test get token sold while ico pre sale', async () => {
			return await getTokenSoldTest(accounts[0], {
				phase: 1,
				from: accounts[0]
			});
		});

		it('test get token sold while ico public sale', async () => {
			return await getTokenSoldTest(accounts[0], {
				phase: 2,
				from: accounts[0]
			});
		});
	});

	describe('getOwnerAddress()', async () => {
		it('test get owner of ico contract', async () => {
			return await getOwnerAddressTest(accounts[0], {
				from: accounts[0]
			});
		});
	});

	describe('setEthFundDeposit()', async () => {
		it('test set ether fund deposit with owner', async () => {
			return await setEthFundDepositTest(accounts[0], {
				addr: '0x589a0819824dE6486243Cfe4DE29230bD99F511f',
				from: accounts[0],
				expected: '0x589a0819824dE6486243Cfe4DE29230bD99F511f'
			});
		});

		it('test set ether fund deposit without owner', async () => {
			return await setEthFundDepositTest(accounts[0], {
				addr: '0x589a0819824dE6486243Cfe4DE29230bD99F511f',
				from: accounts[1],
				expected: '0x589a0819824dE6486243Cfe4DE29230bD99F510f'
			});
		});

		it('test set ether fund deposit with address 0x0', async () => {
			return await setEthFundDepositTest(accounts[0], {
				addr: '0x0',
				from: accounts[0],
				expected: '0x589a0819824dE6486243Cfe4DE29230bD99F510f'
			});
		});
	});

	describe('authoriseAccount()', async () => {
		it('test authorised single account with owner', async() => {
			return await authoriseAccountTest(accounts[0], {
				cs: accounts[1],
				whom: '0x589a0819824dE6486243Cfe4DE29230bD99F511f',
				from: accounts[0],
				expected: true
			});
		});
		it('test authorised single account without owner', async() => {
			return await authoriseAccountTest(accounts[0], {
				cs: accounts[1],
				whom: '0x589a0819824dE6486243Cfe4DE29230bD99F511f',
				from: accounts[2],
				expectThrow: true,
				expected: false
			});
		});
		it('test authorised single account with crowd sale', async() => {
			return await authoriseAccountTest(accounts[0], {
				cs: accounts[1],
				whom: '0x589a0819824dE6486243Cfe4DE29230bD99F511f',
				from: accounts[1],
				expected: true
			});
		});
	});

	describe('authoriseManyAccounts()', async () => {
		var whoms = [];
		for (var i = 0; i < 3; i++) {
			whoms.push('0x' + crypto.randomBytes(40).toString('hex').substr(0, 40));
		}
		it('test authorised many accounts with owner', async () => {
			return await authoriseManyAccountsTest(accounts[0], {
				cs: accounts[1],
				whoms: whoms,
				from: accounts[0],
				expected: true
			});
		});
		it('test authorised many accounts without owner', async () => {
			return await authoriseManyAccountsTest(accounts[0], {
				cs: accounts[1],
				whoms: whoms,
				from: accounts[2],
				expected: true
			});
		});
		it('test authorised many accounts with crowd sale', async () => {
			return await authoriseManyAccountsTest(accounts[0], {
				cs: accounts[1],
				whoms: whoms,
				from: accounts[1],
				expected: true
			});
		});
	});
});

async function authoriseManyAccountsTest(account, params) {
	const {cs, whoms, from, expected, expectThrow} = params;
	const tp = await tokenTP(account);
	const setCS = await ethTransaction(tp.setCS(cs, {from: account}));
	const tx = await ethTransaction(tp.authoriseManyAccounts(whom, {from: from}));
	const auth = true;
	whoms.forEach((whom) => {
		const authorised = await ethCall(tp.getAuth(whom));
		if (!authorised.returnValue) {
			auth = false;
			break;
		}
	});
	assert.equal(auth, expected, 'many account should be allow');
}

async function authoriseAccountTest(account, params) {
	const {cs, whom, from, expected, expectThrow} = params;
	const tp = await tokenTP(account);
	const setCS = await ethTransaction(tp.setCS(cs, {from: account}));
	const tx = await ethTransaction(tp.authoriseAccount(whom, {from: from}));
	const authorised = await ethCall(tp.getAuth(whom));
	assert.equal(authorised.returnValue, expected, 'account ' + whom + ' should be allow ' + expected);
}

async function setEthFundDepositTest(account, params) {
	const {addr, from, expected} = params;
	const tp = await tokenTP(account);
	const tx = await ethTransaction(tp.setEthFundDeposit(addr, {from: from}));
	const deposit = await ethCall(tp.ethFundDeposit.call());
	assert.equal(deposit.returnValue.toString(), expected.toLowerCase(), 'Deposit address should be ' + expected.toLowerCase());
}

async function getOwnerAddressTest(account, params) {
	const {from} = params;
	const tp = await tokenTP(account);
	const func = await ethCall(tp.getOwnerAddress({from: from}));
}

async function getTokenSoldTest(account, params) {
	const {phase, from} = params;
	const tp = await tokenTP(account);
	const setPhase = await ethTransaction(tp.changePhaseTime(phase));
	const func = await ethCall(tp.getTokenSold({from: from}));
}

async function getTotalETHOfAddressTest(account, params) {
	const {addr, from} = params;
	const tp = await tokenTP(account);
	const func = await ethCall(tp.getTotalETHOfAddress(addr, {from: from}));
}

async function getTotalTokenOfAddressTest(account, params) {
	const {addr, from} = params;
	const tp = await tokenTP(account);
	const func = await ethCall(tp.getTotalTokenOfAddress(addr, {from: from}));
}

async function calculateTokensTest(account, params) {
	const {phase, value, from, expected} = params;
	const tp = await tokenTP(account);
	const call = await ethCall(tp.calculateTokens(phase, value, {from: from}));
	assert.equal(call.returnValue.toNumber(), expected, 'Token receive should be ' + expected);
}

async function getCurrentICOPhaseTest(account, params) {
	const {phase, from} = params;
	const tp = await tokenTP(account);
	const setPhase = await ethTransaction(tp.changePhaseTime(phase));
	const func = await ethCall(tp.getCurrentICOPhase({from: from}));
}

async function eth2SPXTokenTest(account, params) {
	const {value, from, phase, expected} = params;
	const tp = await tokenTP(account);
	const setPhase = await ethTransaction(tp.changePhaseTime(phase));
	const call = await ethCall(tp.eth2SPXToken(value, {from: from}));
	assert.equal(call.returnValue.toNumber(), expected, 'Token receive should be ' + expected);
}

async function reFundETHTest(account, params) {
	const {recipient, from, value, pause, expected, expectThrow, phase, reNotExists} = params;
	const tp = await tokenTP(account);
	const authFunc = await ethTransaction(tp.setAuth(recipient));
	const setPhase = await ethTransaction(tp.changePhaseTime(1));
	if (reNotExists == undefined || !reNotExists) {
		const buy = await ethTransaction(tp.buy({from: recipient, value: 1e18}));
	}
	if (phase == undefined) {
		const setPhase = await ethTransaction(tp.changePhaseTime(5));
	}else{
		const setPhase = await ethTransaction(tp.changePhaseTime(phase));
	}
	if (pause != undefined && pause) {
		const funcPause = await ethTransaction(tp.pause({from: account}));
	}
	const tx = await ethTransaction(tp.reFundETH(recipient, {from: from, value: value}));
	if (expectThrow) {
		tx.assertThrewError();
	}
	if (expected != undefined) {
		const getTotalETH = await ethCall(tp.getTotalETHOfAddress.call(recipient));
		assert.equal(getTotalETH.returnValue.toNumber(), expected, 'The balance of ' + recipient + ' in ico should be ' + expected);
	}
}

async function payTokensToAddressTest(account, params) {
	const {recipient, from, phase, pause, expected, expectThrow, recipientExists} = params;
	const tp = await tokenTP(account);
	const authFunc = await ethTransaction(tp.setAuth(recipient));
	const setPhase = await ethTransaction(tp.changePhaseTime(1));
	if (recipientExists == undefined || recipientExists) {
		const buy = await ethTransaction(tp.buy({from: recipient, value: 1e18}));
	}
	if (phase == undefined) {
		const setPhase = await ethTransaction(tp.changePhaseTime(5));
	}else{
		const setPhase = await ethTransaction(tp.changePhaseTime(phase));
	}
	if (pause != undefined && pause) {
		const funcPause = await ethTransaction(tp.pause({from: account}));
	}
	const tx = await ethTransaction(tp.payTokensToAddress(recipient, {from: from}));
	if (expectThrow) {
		tx.assertThrewError();
	}
	if (expected != undefined) {
		const getTotalBalance = await ethCall(tp.getTotalTokenOfAddress.call(recipient));
		assert.equal(getTotalBalance.returnValue.toNumber(), expected, 'The balance of ' + recipient + ' should be ' + expected);
	}
}

async function buyTest(account, params) {
	const {pause, from, value, unauthorised, phase, expected, expectThrow} = params;
	const tp = await tokenTP(account);
	if (unauthorised == undefined || !unauthorised) {
		const authFunc = await ethTransaction(tp.setAuth(from));
	}
	if (pause != undefined && pause) {
		const funcPause = await ethTransaction(tp.pause({from: account}));
	}
	const setPhase = await ethTransaction(tp.changePhaseTime(phase));
	const curPhase = await ethCall(tp.getCurrentICOPhase.call());
	const tx = await ethTransaction(tp.buy({from: from, value: value}));
	if (expectThrow != undefined) {
		tx.assertThrewError();
	}
	const getTotalBalance = await ethCall(tp.getTotalTokenOfAddress.call(from));
	assert.equal(getTotalBalance.returnValue.toNumber(), expected, 'This balance of ' + from + ' should be ' + expected);
}

async function unpauseTest(account, params) {
	const {pause, expected, expectThrow, from} = params;
	const tp = await tokenTP(account);
	if (pause) {
		const tx1 = await ethTransaction(tp.pause({from: account}));
	}
	const tx = await ethTransaction(tp.unpause({from: from}));
	if (expectThrow) {
		tx.assertThrewError();
	}
	if (expected != undefined) {
		const call = await ethCall(tp.paused.call());
		assert.equal(call.returnValue, expected, 'pause should be return ' + expected);
	}
}

async function pauseTest(account, params) {
	const {pause, expected, expectThrow, from} = params;
	const tp = await tokenTP(account);
	if (pause) {
		const tx1 = await ethTransaction(tp.pause({from: account}));
	}
	const tx = await ethTransaction(tp.pause({from: from}));
	if (expectThrow) {
		tx.assertThrewError();
	}
	if (expected != undefined) {
		const call = await ethCall(tp.paused.call());
		assert.equal(call.returnValue, expected, 'pause should be return ' + expected);
	}
}

async function hasEndTest(account) {
	const tp = await tokenTP(account);
	const hasEnd = await ethCall(tp.hasEnd());
	assert.equal(hasEnd.returnValue, false, 'ico has end should be return false');
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