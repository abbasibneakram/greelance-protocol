const crypto = require('crypto')

const secretKey = process.env.SECRET_KEY

const encryptData = (data) => {
    const iv = crypto.randomBytes(16)
    const keyBuffer = Buffer.from(secretKey, 'hex')
    const cipher = crypto.createCipheriv('aes-256-cbc', keyBuffer, iv)
    let encrypted = cipher.update(JSON.stringify(data), 'utf8', 'hex')
    encrypted += cipher.final('hex')
    const encryptedData = iv.toString('hex') + encrypted
    return encryptedData
}

const decryptData = (encryptedData) => {
    const keyBuffer = Buffer.from(secretKey, 'hex')
    const iv = Buffer.from(encryptedData.slice(0, 32), 'hex')
    const encrypted = encryptedData.slice(32)
    const decipher = crypto.createDecipheriv('aes-256-cbc', keyBuffer, iv)

    let decrypted = decipher.update(encrypted, 'hex', 'utf8')
    decrypted += decipher.final('utf8')

    return JSON.parse(decrypted)
}

module.exports = { encryptData, decryptData }
