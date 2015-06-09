# coding: utf-8
# process.py clean and zhuyin raw corpus
# ylxdzsw@gmail.com 2015.6.6
import json
import os
import pypinyin
import sys
import io

##############
# main pipes #
##############

seperators = (',','，','。','！','？','.','!','?',';','；') # \n不加在里面是因为材料本身的问题：从web上直接用复制的话会有多余的换行符

def rectify():
	pypinyin.load_single_dict({
		ord('的'):'de,di',
		ord('地'):'de,di',
		ord('了'):'le,liao',
		ord('着'):'zhe,zhuo',
		ord('还'):'hai,huan'
	})


def read(fin): #分句
	sin = fin.read()
	line = ""
	for char in sin:
		if char in seperators: 
			if len(line) > 0:
				yield line
				line = ""
		else:
			line += char
	if len(line) > 0:
		yield line

def clean(line): #处理特殊字符
	return ''.join(filter(lambda char:'\u4e00' <= char <= '\u9fff', line))
	# ''.join((for i in line if '\u4e00' <= i <= '\u9fff')) 哪个更快？

def zhuyin(line):
	pinyin = '\''.join((asterisk(i) for j in pypinyin.pinyin(line, style=pypinyin.NORMAL, errors='ignore', heteronym=False) for i in j))
	return line,pinyin

def writer(fout):
	return lambda line,pinyin:fout.buffer.write((json.dumps({"sentence":line,"pinyin":pinyin})+"\n").encode('utf-8'))

###########
# helpers #
###########

yunmu = ('a','o','e','i','u','v')
#yunmu = "aoeiuv", which faster?

def asterisk(word):
	if word[0] in yunmu:
		return '*' + word
	else:
		return word

#########
# entry #
#########

if __name__ == '__main__':
	rectify()

	fin   = io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8')
	fout  = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
	
	write = writer(fout)
	for i in read(fin):
		line = clean(i)
		if len(line) > 0:
			write(*zhuyin(line))