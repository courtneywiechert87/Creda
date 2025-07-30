import { describe, it, expect, beforeEach } from "vitest"

const mockContract = {
  admin: "ST000000000000000000002AMW42H", // Initial contract deployer
  registry: new Map<string, any>(),
  status: new Map<string, boolean>(),
  aliases: new Map<string, string>(),

  isAdmin(caller: string) {
    return caller === this.admin
  },

  registerIdentity(caller: string, did: string, metadataHash: string) {
    if (did === "") return { error: 103 } // ERR-INVALID-INPUT
    if (this.registry.has(caller)) return { error: 101 } // ERR-ALREADY-REGISTERED

    this.registry.set(caller, {
      did,
      metadataHash,
      createdAt: 1000, // Mock block-height
    })
    this.status.set(caller, true)
    return { value: true }
  },

  updateMetadata(caller: string, newHash: string) {
    if (!this.registry.has(caller)) return { error: 102 } // ERR-NOT-FOUND
    const existing = this.registry.get(caller)
    this.registry.set(caller, {
      ...existing,
      metadataHash: newHash,
    })
    return { value: true }
  },

  deactivateIdentity(caller: string, identity: string) {
    if (!this.isAdmin(caller)) return { error: 100 } // ERR-NOT-AUTHORIZED
    if (!this.status.has(identity)) return { error: 102 }
    this.status.set(identity, false)
    return { value: true }
  },

  activateIdentity(caller: string, identity: string) {
    if (!this.isAdmin(caller)) return { error: 100 }
    if (!this.status.has(identity)) return { error: 102 }
    this.status.set(identity, true)
    return { value: true }
  },

  addAlias(caller: string, alias: string) {
    if (!this.registry.has(caller)) return { error: 102 }
    this.aliases.set(alias, caller)
    return { value: true }
  },

  transferAdmin(caller: string, newAdmin: string) {
    if (!this.isAdmin(caller)) return { error: 100 }
    this.admin = newAdmin
    return { value: true }
  },

  getIdentity(owner: string) {
    return this.registry.get(owner) || null
  },

  isIdentityActive(owner: string) {
    return this.status.get(owner) || false
  },

  getAliasOwner(alias: string) {
    return this.aliases.get(alias) || null
  },
}

describe("Creda Registry Contract", () => {
  const user1 = "ST1AAA..."
  const user2 = "ST1BBB..."
  const user3 = "ST1CCC..."

  beforeEach(() => {
    mockContract.registry = new Map()
    mockContract.status = new Map()
    mockContract.aliases = new Map()
    mockContract.admin = "ST000000000000000000002AMW42H"
  })

  it("should register a new identity", () => {
    const result = mockContract.registerIdentity(user1, "did:creda:user1", "abcd1234")
    expect(result).toEqual({ value: true })
    expect(mockContract.getIdentity(user1)?.did).toBe("did:creda:user1")
  })

  it("should prevent duplicate identity registration", () => {
    mockContract.registerIdentity(user1, "did:creda:user1", "abcd1234")
    const result = mockContract.registerIdentity(user1, "did:creda:user1", "abcd1234")
    expect(result).toEqual({ error: 101 })
  })

  it("should allow metadata update", () => {
    mockContract.registerIdentity(user1, "did:creda:user1", "hash1")
    const result = mockContract.updateMetadata(user1, "hash2")
    expect(result).toEqual({ value: true })
    expect(mockContract.getIdentity(user1)?.metadataHash).toBe("hash2")
  })

  it("should allow admin to deactivate and reactivate identity", () => {
    mockContract.registerIdentity(user2, "did:creda:user2", "meta2")
    const deact = mockContract.deactivateIdentity(mockContract.admin, user2)
    expect(deact).toEqual({ value: true })
    expect(mockContract.isIdentityActive(user2)).toBe(false)

    const act = mockContract.activateIdentity(mockContract.admin, user2)
    expect(act).toEqual({ value: true })
    expect(mockContract.isIdentityActive(user2)).toBe(true)
  })

  it("should allow alias mapping", () => {
    mockContract.registerIdentity(user1, "did:creda:user1", "meta1")
    const result = mockContract.addAlias(user1, "user1")
    expect(result).toEqual({ value: true })
    expect(mockContract.getAliasOwner("user1")).toBe(user1)
  })

  it("should allow admin transfer", () => {
    const result = mockContract.transferAdmin(mockContract.admin, user3)
    expect(result).toEqual({ value: true })
    expect(mockContract.admin).toBe(user3)
  })

  it("should reject unauthorized admin actions", () => {
    const result = mockContract.deactivateIdentity(user1, user2)
    expect(result).toEqual({ error: 100 })
  })
})
