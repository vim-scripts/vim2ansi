说明：

	将文件按vim的语法加亮输出为Ansi控制序列
	在tohtml的脚本基础上修改而成

安装方法：

	1.解压缩
	2.将syntax和plugin中的文件拷入相应目录
	3.安装帮助文档
		cp doc/toansi.txt ~/.vim/doc/toansi.txt
	  	vim
	  	:helptags ~/.vim/doc
		:q

使用方法：

	在Normal模式下输入 :TOansi 运行脚本，输出结果到分割窗口
	支持设定转换范围，可以参考 :help TOhtml 里的说明

版本更新
2005/02/22 Ver 1.3b
	加入help文档
2004/12/14 Ver 1.3a
	修正了一个处理"<"的错误
	加入了英文说明文档
2004/11/15 Ver 1.3
	改进了算法，大大提高了脚本运行速度，执行时间便为原来的1/3左右
	感谢dodowolf@drl反映问题
2004/11/12 Ver 1.2
	加入了对gui下实际色彩的猜测算法
2004/11/11 Ver 1.1
	修正了当T_Co = 16时的输出错误
	修正了AnsiOpening和AnsiClosing的匹配错误
	设置gui模式下高亮为默认属性
2004/11/10 Ver 1.0
	初始版本

rogerz@smth
2004年12月14日
