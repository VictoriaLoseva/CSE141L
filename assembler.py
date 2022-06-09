T1R = 1
T2R = 2
TI = 3
TLUT = 4

OPCODE = {  'lw':   '0000',\
            'inc':  '0001',\
            'luv':  '0010',\
            'and':  '0011',\
            'cpy':  '0100',\
            'sb':   '0101',\
            'gb':   '0110',\
            'flip': '0111',\
            'xor':  '1000',\
            'loop': '1001',\
            'shr':  '1010',\
            'goto': '1011',\
            'beq':  '1100',\
            'rb':   '1101' }

TYPE_CHART = {  'lw':   T1R,\
                'inc':  TLUT,\
                'luv':  T1R,\
                'and':  T2R,\
                'cpy':  T2R,\
                'sb':   TI,\
                'gb':   TI,\
                'flip': TI,\
                'xor':  T2R,\
                'loop': TLUT,\
                'shr':  T2R,\
                'goto': TLUT,\
                'beq':  T2R,\
                'rb':   TI }

REG_CODE = {'r1': '00',\
            'r2': '01',\
            'r3': '10',\
            'r4': '11'}

class Instruction:
    def __init__(self, instruction, pc = None):
        self.instruction = instruction
        self.pc = pc
        self.parsedList = []
        self.opcode = ''
        self.rd = ''
        self.rs = ''
        self.h = ''
        self.lut = ''
        self.imm = ''
        self.machineCode = ''


    def getMachineCode(self):
        self.getParsedList()
        self.parseOpcode()
        self.parse()
        self.machineCode = self.opcode + self.rd + self.rs + self.h + self.lut + self.imm
        return self.machineCode

    def parse(self):
        l = self.parsedList
        self.type = TYPE_CHART[l[0]]
        if self.type == T1R:
            self.rd = REG_CODE[l[1]]
            self.lut = str(bin(int(l[2])))[2:]
            self.lut = self.formatBinary(self.lut, 3)

        elif self.type == T2R:
            self.rd = REG_CODE[l[1]]
            self.rs = REG_CODE[l[2]]
            self.h = '1'

        elif self.type == TI:
            if l[0] == 'rb':
                self.rs = '00'
                self.imm = '000'
            else:
                self.rs = REG_CODE[l[1]]
                self.imm = str(bin(int(l[2])))[2:]
                self.imm = self.formatBinary(self.imm, 3)

        elif self.type == TLUT:
            self.lut = str(bin(int(l[1])))[2:]
            self.lut = self.formatBinary(self.lut, 5)

        return

    def parseOpcode(self):
        self.opcode = OPCODE[self.parsedList[0]]
        return self.opcode

    def getParsedList(self):
        if self.instruction == None:
            return -1
        ins = self.instruction
        for i in range(len(ins)):
            if ins[i] == ',':
                ins = ins[:i] + ' ' + ins[i+1:]
        ins = ins.lower().split(' ')
        ins = [x for x in ins if x != '']
        self.parsedList = ins
        return

    def formatBinary(self, binstr, formatLength):
        while len(binstr) < formatLength:
            binstr = '0' + binstr
        while len(binstr) > formatLength:
            binstr = binstr[1:]
        return binstr

while(True):
    print("**************************")
    instruction_string = input("Enter instruction: ")
    ins = Instruction(instruction_string)
    code = ins.getMachineCode()
    print("Machine code is: ", code)
    print("**************************")
    print()
