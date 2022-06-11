ZERO = 0

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

LUT = []
LUT.append(ZERO)
LUT_next_index = 1

TAG = {}
TAG[ZERO] = 0

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
        if self.getParsedList() == -1:
            return None
        self.parseTag()
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

    def parseTag(self):
        firstItem = self.parsedList[0]
        if firstItem[-1] == ':':
            firstItem = firstItem[:-1]
            self.parsedList.pop(0)
            if firstItem not in TAG.keys():
                # first time appear
                LUT.append(self.pc)
                global LUT_next_index
                TAG[firstItem] = LUT_next_index
                LUT_next_index += 1
            else:
                # replace previous tag
                index = TAG[firstItem]
                LUT[index] = self.pc

    def getParsedList(self):
        if self.instruction == None or self.instruction == '':
            return -1
        ins = self.instruction
        if ins[-1] == '\n':
            ins = ins[:-1]
        for i in range(len(ins)):
            if ins[i] == ',' or ins[i] == '\t':
                ins = ins[:i] + ' ' + ins[i+1:]
        ins = ins.lower().split(' ')
        ins = [x for x in ins if x != '']
        self.parsedList = ins
        if len(ins) < 1:
            return -1
        return

    def formatBinary(self, binstr, formatLength):
        while len(binstr) < formatLength:
            binstr = '0' + binstr
        while len(binstr) > formatLength:
            binstr = binstr[1:]
        return binstr

def write_machine_code_to_file(input_file, output_file):
    lines = []
    machine_code_list = []

    # read instructions from input file
    with open(input_file, 'r') as f:
        lines = f.readlines()
    f.close()

    # convert instruction to machine code
    for addr in range(len(lines)):
        ins_str = lines[addr]
        ins = Instruction(ins_str, addr)
        machine_code = ins.getMachineCode()
        machine_code_list.append(machine_code)

    # write machine code to output file
    f = open(output_file, "w")
    print('file created')
    for code in machine_code_list:
        if code:
            f.write(code+'\n')
    f.close()


write_machine_code_to_file('program.sv', "machineCode.txt")
print(LUT)
