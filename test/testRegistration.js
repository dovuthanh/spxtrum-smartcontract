const _ = require('lodash');
const { ethTransaction, ethCall } = require('./helper');
console.log(artifacts.require('SP8TokenSale.sol'));
const SP8ICO = artifacts.require('SP8TokenSale.sol');
const BaseRegistration = artifacts.require('BaseRegistraton.sol');
const SongRegistration = artifacts.require('SongRecordingRegistraton.sol');
const WorkRegistration = artifacts.require('WorkRegistraton.sol');
const MassRegistration = artifacts.require('MassRegistration.sol');
const License = artifacts.require('License.sol');

contract('BaseRegistration', async (accounts) => {
	describe('verifyDigitalSignatureOfSong()', async () => {
		it('test verify digital signature of song', async () => {
			return await verifyDigitalSignatureOfSongTest(accounts[0], {
				songOwner: 0xf7cc551106a1f4e2843a3da0c477b6f77fa4a09d,
				hashOfSong: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				from: accounts[0]
			});
		});
	});

	describe('changOwnerAddress()', async () => {
		it('test change owner address with correct deployer', async () => {
			return await changOwnerAddressTest(accounts[0], {
				newOwner: accounts[1],
				from: accounts[0]
			});
		});

		it('test change owner address without deployer', async () => {
			return await changOwnerAddressTest(accounts[0], {
				newOwner: accounts[1],
				from: accounts[1]
			});
		});
	});
});

contract('SongRecordingRegistration', async (accounts) => {
	const init = {
		owner: accounts[1], 
		songTitle: 'Hello', 
		hashOfSong: '0x123456', 
		digital: '0x654321', 
		addrDispute: '', 
		datePublish: '', 
		professionName: 'VKS', 
		duration: '03:12', 
		arrRoyaltyPercent: [], 
		arrRoyaltyAddress: []
	};
	describe('getRegistration()', async () => {
		it('test get information of song registration', async () => {
			return await getRegistrationTest({
				init,
				from: accounts[0]
			});
		});
	});

	describe('royaltyChangePercent()', async () => {
		it('test change royalty percent with correct data', async () => {
			return await royaltyChangePercentTest(accounts[0], {
				init,
				royaltyAddress: accounts[2],
				percent: 20,
				from: accounts[0]
			});
		});

		it('test change royalty percent without deployer', async () => {
			return await royaltyChangePercentTest(accounts[0], {
				init,
				royaltyAddress: accounts[2],
				percent: 20,
				from: accounts[1]
			});
		});

		it('test change royalty percent with royalty address 0x0', async () => {
			return await royaltyChangePercentTest(accounts[0], {
				init,
				royaltyAddress: 0x0,
				percent: 20,
				from: accounts[0]
			});
		});

		it('test change royalty percent with percent equal zero', async () => {
			return await royaltyChangePercentTest(accounts[0], {
				init,
				royaltyAddress: accounts[2],
				percent: 0,
				from: accounts[0]
			});
		});
	});

	describe('royaltyConfirmed()', async () => {
		it('test royalty confirmed with correct data', async () => {
			return await royaltyConfirmedTest(accounts[0], {
				init,
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});

		it('test royalty confirmed without deployer', async () => {
			return await royaltyConfirmedTest(accounts[0], {
				init,
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[1]
			});
		});

		it('test royalty confirmed with wrong message', async () => {
			return await royaltyConfirmedTest(accounts[0], {
				init,
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3ee,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});

		it('test royalty confirmed with wrong signature', async () => {
			return await royaltyConfirmedTest(accounts[0], {
				init,
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855ba5,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});

		it('test royalty confirmed with confirmed is true', async () => {
			return await royaltyConfirmedTest(accounts[0], {
				init,
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});

		it('test royalty confirmed with confirmed is false', async () => {
			return await royaltyComfirmedTest(accounts[0], {
				init,
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: false,
				from: accounts[0]
			});
		});

		it('test royalty confirmed with total percent greater than 100', async () => {
			return await royaltyConfirmedTest(accounts[0], {
				init,
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});

		it('test royalty confirmed with royalty not exists', async () => {
			return await royaltyConfirmedTest(accounts[0], {
				init,
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});
	});

	describe('getRoyaltyPercent()', async () => {
		it('test get royalty percent with royalty exists', async () => {
			return await getRoyaltyPercentTest(accounts[0], {
				init,
				address: accounts[2],
				exists: true
			});
		});

		it('test get royalty percent with royalty not exists', async () => {
			return await getRoyaltyPercentTest(accounts[0], {
				init,
				address: accounts[2],
				exists: false
			});
		});
	});

	describe('getRoyaltyExists()', async () => {
		it('test get royalty exists with royalty exists', async () => {
			return await getRoyaltyExistsTest(accounts[0], {
				init,
				address: accounts[2],
				exists: true
			});
		});

		it('test get royalty exists with royalty not exists', async () => {
			return await getRoyaltyExistsTest(accounts[0], {
				init,
				address: accounts[2],
				exists: false
			});
		});
	});

	describe('getRoyaltyPartners()', async () => {
		it('test get list royalty partners', async () => {
			return await getRoyaltyPartnersTest(accounts[0], {
				init
			});
		});
	});

	describe('checkingDispute()', async () => {
		it('test checking dispute with song disputed', async () => {
			return await checkingDisputeTest(accounts[0], {
				init,
				dispute: accounts[2],
				current: accounts[1],
				from: accounts[0]
			});
		});

		it('test checking dispute with song undisputed', async () => {
			return await checkingDisputeTest(accounts[0], {
				init,
				dispute: accounts[2],
				current: accounts[1],
				from: accounts[0]
			});
		});

		it('test checking dispute with address dispute 0x0', async () => {
			return await checkingDisputeTest(accounts[0], {
				init,
				dispute: 0x0,
				current: accounts[1],
				from: accounts[0]
			});
		});

		it('test checking dispute without owner', async () => {
			return await checkingDisputeTest(accounts[0], {
				init,
				dispute: accounts[2],
				current: accounts[1],
				from: accounts[1]
			});
		});
	});

	describe('setDispute()', async () => {
		it('test checking dispute with deployer', async () => {
			return await setDisputeTest(accounts[0], {
				init,
				dispute: accounts[2],
				from: accounts[0]
			});
		});

		it('test checking dispute without deployer', async () => {
			return await setDisputeTest(accounts[0], {
				init,
				dispute: accounts[2],
				from: accounts[1]
			});
		});
	});
});

contract('MassRegistration', async (accounts) => {
	const init = {
		owner: accounts[1],
		hash: '0x123456',
		digital: '0x654321' 
	};

	describe('getRoyaltyPercent()', async () => {
		it('test get royalty percent with correct data', async () => {
			return await getMassRoyaltyPercentTest(accounts[0], {
				init,
				hash: '0x123456',
				index: 1
			});
		});

		it('test get royalty percent with index greater than five', async () => {
			return await getMassRoyaltyPercentTest(accounts[0], {
				init,
				hash: '0x123456',
				index: 6
			});
		});
	});

	describe('getRoyaltyExists()', async () => {
		it('test get royalty exists = true', async () => {
			return await getMassRoyaltyExistsTest(accounts[0], {
				init,
				hash: '0x123456',
				royalty: accounts[1]
			});
		});

		it('test get royalty exists = false', async () => {
			return await getMassRoyaltyExistsTest(accounts[0], {
				init,
				hash: '0x123456',
				royalty: accounts[1]
			});
		});
	});

	describe('getTotalPercent()', async () => {
		it('test get royalty total percent of song exists in mass', async () => {
			return await getMassTotalPercentTest(accounts[0], {
				init,
				hash: '0x123456'
			});
		});
		it('test get royalty total percent of song not exists in mass', async () => {
			return await getMassTotalPercentTest(accounts[0], {
				init,
				hash: '0x123456'
			});
		});
	});

	describe('getRoyaltyPartners()', async () => {
		it('test get royalty of song exists in mass', async () => {
			return await getMassRoyaltyPartnersTest(accounts[0], {
				init,
				hash: '0x123456'
			});
		});
		it('test get royalty of song not exists in mass', async () => {
			return await getMassRoyaltyPartnersTest(accounts[0], {
				init,
				hash: '0x123456'
			});
		});
	});

	describe('royaltyChangePercent()', async () => {
		it('test royalty change percent with correct data', async () => {
			return await massRoyaltyChangePercentTest(accounts[0], {
				init,
				hash: '0x123456',
				royalty: accounts[1],
				percent: 20,
				from: accounts[0]
			});
		});
		it('test royalty change percent without owner', async () => {
			return await massRoyaltyChangePercentTest(accounts[0], {
				init,
				hash: '0x123456',
				royalty: accounts[1],
				percent: 20,
				from: accounts[1]
			});
		});
		it('test royalty change percent with hash of song is empty', async () => {
			return await massRoyaltyChangePercentTest(accounts[0], {
				init,
				hash: '',
				royalty: accounts[1],
				percent: 20,
				from: accounts[0]
			});
		});
		it('test royalty change percent with royalty address 0x0', async () => {
			return await massRoyaltyChangePercentTest(accounts[0], {
				init,
				hash: '0x123456',
				royalty: 0x0,
				percent: 20,
				from: accounts[0]
			});
		});
		it('test royalty change percent with percent is zero', async () => {
			return await massRoyaltyChangePercentTest(accounts[0], {
				init,
				hash: '0x123456',
				royalty: accounts[1],
				percent: 0,
				from: accounts[0]
			});
		});
		it('test royalty change percent with royalty exists in temp', async () => {
			return await massRoyaltyChangePercentTest(accounts[0], {
				init,
				hash: '0x123456',
				royalty: accounts[1],
				percent: 20,
				from: accounts[0],
				temp: true
			});
		});
	});

	describe('royaltyConfirmed()', async () => {
		it('test royalty confirmed with correct data', async () => {
			return await massRoyaltyConfirmedTest(accounts[0], {
				init,
				hash: '0x123456',
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});
		it('test royalty confirmed without owner', async () => {
			return await massRoyaltyConfirmedTest(accounts[0], {
				init,
				hash: '0x123456',
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[1]
			});
		});
		it('test royalty confirmed with wrong message', async () => {
			return await massRoyaltyConfirmedTest(accounts[0], {
				init,
				hash: '0x123456',
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3ee,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});
		it('test royalty confirmed with wrong signature', async () => {
			return await massRoyaltyConfirmedTest(accounts[0], {
				init,
				hash: '0x123456',
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174ca,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});
		it('test royalty confirmed with confirmed is false', async () => {
			return await massRoyaltyConfirmedTest(accounts[0], {
				init,
				hash: '0x123456',
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: false,
				from: accounts[0]
			});
		});
		it('test royalty confirmed with royalty exists', async () => {
			return await massRoyaltyConfirmedTest(accounts[0], {
				init,
				hash: '0x123456',
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});
		it('test royalty confirmed with royalty not exists', async () => {
			return await massRoyaltyConfirmedTest(accounts[0], {
				init,
				hash: '0x123456',
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});
		it('test royalty confirmed with percent greater than total', async () => {
			return await massRoyaltyConfirmedTest(accounts[0], {
				init,
				hash: '0x123456',
				message: 0x55291cd38a2f28632d89f55675f4ea128304f78e76c50a04880b165b72dcf3e6,
				r: 0x0596df171b611298605e3857086bfc28d6d041abc50d3536011ab718fb9174c5,
				s: 0x379e002f545acbd8c0fb8f18aa1de0475e164ab68ebce9cd014c674726855b95,
				v: 0x1b,
				confirmed: true,
				from: accounts[0]
			});
		});
	});
});

contract('Licensing', async(accounts) => {
	const init = {
		buyerAddress: accounts[1],
		territority: 'USA',
		right: 'Physical',
		period: 12,
		hash: '0x123456789'
	}
	describe('getContractStatus()', async () => {
		it('test get status while pending', async () => {
			return await getContractStatusTest(accounts[0], {
				init,
				state: 0
			});
		});
		it('test get status while licensed', async () => {
			return await getContractStatusTest(accounts[0], {
				init,
				state: 1
			});
		});
		it('test get status while expried', async () => {
			return await getContractStatusTest(accounts[0], {
				init,
				state: 2
			});
		});
	});

	describe('updatePrice()', async () => {
		it('test update price with correct data', async () => {
			return await updatePriceTest(accounts[0], {
				init,
				price: 20,
				from: accounts[0]
			});
		});
		it('test update price without owner', async () => {
			return await updatePriceTest(accounts[0], {
				init,
				price: 20,
				from: accounts[1]
			});
		});
		it('test update price with price is zero', async () => {
			return await updatePriceTest(accounts[0], {
				init,
				price: 0,
				from: accounts[0]
			});
		});
		it('test update price with expried', async () => {
			return await updatePriceTest(accounts[0], {
				init,
				price: 20,
				from: accounts[0],
				expried: true
			});
		});
		it('test update price with completed is true', async () => {
			return await updatePriceTest(accounts[0], {
				init,
				price: 20,
				from: accounts[0],
				completed: true
			});
		});
	});
});

async function updatePriceTest(account, params) {
	const {init, price, from} = params;
	const tp = await licenseTP(account, init);
	const func = await ethTransaction(tp.updatePrice(price, {from: from}));
}

async function getContractStatusTest(account, params) {
	const {init, state} = params;
	const tp = await licenseTP(account, init);
	const func = await ethCall(tp.getContractStatus.call());
}

async function massRoyaltyConfirmedTest(account, params) {
	const {init, hash, message, r, s, v, confirmed, from} = params;
	const tp = await massRegistrationTP(account, init);
	const func = await ethTransaction(tp.royaltyConfirmed(hash, message, r, s, v, confirmed, {from: from}));
}

async function massRoyaltyChangePercentTest(account, params) {
	const {init, hash, royalty, percent, from, temp} = params;
	const tp = await massRegistrationTP(account, init);
	const func = await ethTransaction(tp.royaltyChangePercent(hash, royalty, percent, {from: from}));
	if (temp != undefined) {
		const func2 = await ethTransaction(tp.royaltyChangePercent(hash, royalty, percent+10, {from: from}));
	}
}

async function getMassRoyaltyPartnersTest(account, params) {
	const {init, hash} = params;
	const tp = await massRegistrationTP(account, init);
	const func = await ethCall(tp.getRoyaltyPartners.call(hash));
}

async function getMassTotalPercentTest(account, params) {
	const {init, hash} = params;
	const tp = await massRegistrationTP(account, init);
	const func = await ethCall(tp.getTotalPercent.call(hash));
}

async function getMassRoyaltyExistsTest(account, params) {
	const {init, hash, royalty} = params;
	const tp = await massRegistrationTP(account, init);
	const func = await ethCall(tp.getRoyaltyExists.call(hash, royalty));
}

async function getMassRoyaltyPercentTest(account, params) {
	const {init, hash, index} = params;
	const tp = await massRegistrationTP(account, init);
	const func = await ethCall(tp.getRoyaltyPercent.call(hash, index));
}

async function setDisputeTest(account, params) {
	const {init, dispute, from} = params;
	const tp = await songRegistrationTP(account, init);
	const func = await ethTransaction(tp.setDispute(dispute));
}

async function checkingDisputeTest(account, params) {
	const {init, dispute, current, from} = params;
	const tp = await songRegistrationTP(account, init);
	const func = await ethTransaction(tp.checkingDispute(dispute, current, {from: from}));
}

async function getRoyaltyPartnersTest(account, params) {
	const {init} = params;
	const tp = await songRegistrationTP(account, init);
	const func = await ethCall(tp.getRoyaltyPartners.call());
}

async function getRoyaltyExistsTest(account, params) {
	const {init, address, exists} = params;
	const tp = await songRegistrationTP(account, init);
	const func = await ethCall(tp.getRoyaltyExists.call(address));
}

async function getRoyaltyPercentTest(account, params) {
	const {init, address, exists} = params;
	const tp = await songRegistrationTP(account, init);
	const func = await ethCall(tp.getRoyaltyPercent.call(address));
}

async function royaltyConfirmedTest(account, params) {
	const {init, message, r, s, v, confirmed, from} = params;
	const tp = await songRegistrationTP(account, init);
	const func = await ethTransaction(tp.royaltyConfirmed(message, r, s, v, confirmed, {from: from}));
}

async function royaltyChangePercentTest(account, params) {
	const {init, royaltyAddress, percent, from} = params;
	const tp = await songRegistrationTP(account, init);
	const func = await ethTransaction(tp.royaltyChangePercent(royaltyAddress, percent, {from: from}));
}

async function getRegistrationTest(account, params) {
	const {init, from} = params;
	const tp = await songRegistrationTP(account, init);
	const func = await ethCall(tp.getRegistration.call({from: from}));
}

async function changOwnerAddressTest(account, params) {
	const {newOwner, from} = params;
	const tp = await baseRegistrationTP(account);
	const func = await ethTransaction(tp.changOwnerAddress(newOwner, {from: from}));
}

async function verifyDigitalSignatureOfSongTest(account, params) {
	const {songOwner, hashOfSong, r, s, v, from} = params;
	const tp = await baseRegistrationTP(account);
	const func = await ethCall(tp.verifyDigitalSignatureOfSong.call(owner, hash, r, s, v));
}

async function baseRegistrationTP (account) {
  	return await BaseRegistration.new(
	    {
	    	from: account
	    }
  	);
}

async function songRegistrationTP (account, params) {
	const {owner, songTitle, hashOfSong, digital, addrDispute, datePublish, professionName, duration, arrRoyaltyPercent, arrRoyaltyAddress} = params;
  	return await SongRegistration.new(
  		owner, 
  		songTitle, 
  		hashOfSong, 
  		digital, 
  		addrDispute, 
  		datePublish, 
  		professionName, 
  		duration, 
  		arrRoyaltyPercent, 
  		arrRoyaltyAddress,
	    {
	    	from: account
	    }
  	);
}

async function workRegistrationTP (account, params) {
	const {owner, songTitle, hashOfSong, digital, datePublish, isTempRegistration} = params;
  	return await WorkRegistraton.new(
  		owner,
  		songTitle,
  		hashOfSong,
  		digital,
  		datePublish,
  		isTempRegistration,
	    {
	    	from: account
	    }
  	);
}

async function massRegistrationTP (account, params) {
	const {owner, hash, digital} = params;
  	return await MassRegistration.new(
  		owner,
  		hash,
  		digital,
	    {
	    	from: account
	    }
  	);
}

async function licenseTP (account, params) {
	const initSong = {
		owner: accounts[1], 
		songTitle: 'Hello', 
		hashOfSong: '0x123456', 
		digital: '0x654321', 
		addrDispute: '', 
		datePublish: '', 
		professionName: 'VKS', 
		duration: '03:12', 
		arrRoyaltyPercent: [], 
		arrRoyaltyAddress: []
	};
	const token = await SP8Token.new(30000000000, 'SPXTROS', 'SP8', {from: account});
	const song = await songRegistrationTP(accounts[0], initSong);
  	return await License.new(
  		buyerAddress,
  		token.address,
  		song.address,
  		territority,
  		right,
  		period,
  		hash,
	    {
	    	from: account
	    }
  	);
}