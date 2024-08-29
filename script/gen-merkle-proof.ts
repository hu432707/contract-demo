import { keccak256, solidityPacked } from 'ethers'
import { MerkleTree } from 'merkletreejs'
import whitelist from './data/whitelist-data.json'

function main(){
  const leafNodes = whitelist.map((w) =>
    keccak256(solidityPacked(['address', 'uint256'], [w.account, w.limit])),
  )
  const tree = new MerkleTree(leafNodes, keccak256, { sortPairs: true })
  const root = tree.getHexRoot()
  console.log('merkleRoot', root)

  
  const leaf = keccak256(solidityPacked(['address', 'uint256'], [whitelist[0].account, whitelist[0].limit]))
  const proof = tree.getHexProof(leaf)

  console.log('proof', proof)
}


main()