cimport libc.stdint

cdef extern from "openssl/sha.h":
    ctypedef struct SHA_CTX:
        pass

    cdef enum:
        SHA_DIGEST_LENGTH

    int SHA1_Init(SHA_CTX *c)
    int SHA1_Update(SHA_CTX *c, const void *data, size_t len)
    int SHA1_Final(unsigned char *md, SHA_CTX *c)
    void SHA1_Transform(SHA_CTX *c, const unsigned char *data)


cdef enum:
    SHA_DUMP_MAGIC = 0x5a6a4853


ctypedef struct SHADump:
    libc.stdint.uint32_t magic
    SHA_CTX sha


class DecodeError(Exception):
    pass


cdef class sha1(object):
    cdef SHA_CTX sha

    def __cinit__(self, bytes data=None):
        SHA1_Init(&self.sha)
        if data is not None:
            self.update(data)

    cpdef update(self, bytes data):
        SHA1_Update(&self.sha, <char*> data, len(data))

    cpdef sha1 copy(self):
        obj = sha1()
        obj.sha = self.sha
        return obj

    cpdef bytes digest(self):
        cdef SHA_CTX sha_copy = self.sha
        cdef unsigned char binary[SHA_DIGEST_LENGTH]
        SHA1_Final(binary, &sha_copy)
        return binary[:SHA_DIGEST_LENGTH]

    cpdef str hexdigest(self):
        return self.digest().encode('hex')

    cpdef bytes dumps(self):
        cdef SHADump dump
        dump.magic = SHA_DUMP_MAGIC
        dump.sha = self.sha
        return (<char *>&dump)[:sizeof(SHADump)]

    @staticmethod
    def loads(bytes data):
        if len(data) != sizeof(SHADump):
            raise DecodeError('Invalid object length')
        cdef SHADump *dump = <SHADump*> <char*> data
        if dump.magic != SHA_DUMP_MAGIC:
            raise DecodeError('Magic does not match')
        sha = sha1()
        sha.sha = dump.sha
        return sha
