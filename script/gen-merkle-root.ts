import { keccak256, solidityPacked } from 'ethers'
import { MerkleTree } from 'merkletreejs'
import whitelist from './data/whitelist-data.json'

function main(){
  const leafNodes = whitelist.map((t) =>
    keccak256(solidityPacked(['address', 'uint256'], [t.account, t.limit])),
  )
  const tree = new MerkleTree(leafNodes, keccak256, { sortPairs: true })
  const root = tree.getHexRoot()
  console.log('merkleRoot', root)
}


main()