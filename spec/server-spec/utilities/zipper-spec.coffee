Fs = require "fs-extra"
Q = require "q"
Zipper = require "../../../server/utilities/zipper"

rootFolder = "C:\\Temp\\"
# Assumes that you have a test zip file located at C:\Temp\testsource.zip
# that contains a single file called testsource.txt in it
sourceZip = "#{rootFolder}testsource.zip"
testZip = "#{rootFolder}test.zip"
testText = "#{rootFolder}testsource.txt"
# Also assumes 3 files, C:\Temp\doc1source.txt, C:\Temp\doc2source.txt, C:\Temp\doc3source.txt
txtSource1 = "#{rootFolder}doc1source.txt"
txtSource2 = "#{rootFolder}doc2source.txt"
txtSource3 = "#{rootFolder}doc3source.txt"
txt1 = "#{rootFolder}doc1.txt"
txt2 = "#{rootFolder}doc2.txt"
txt3 = "#{rootFolder}doc3.txt"
sourceZippedFiles = "#{rootFolder}zippedFiles.zip"

describe "Zipper utility", ->
	it "can execute unzipAndDelete", (done) ->
		Q.nfcall(Fs.copy, sourceZip, testZip)
		.catch (err) ->
			console.error(err)
		.then ->
			exists = Fs.existsSync testZip
			expect(exists).toBeTruthy()
			Zipper.unzipAndDelete testZip, rootFolder
		.catch (err) ->
			console.error(err)
		.then ->
			exists = Fs.existsSync testZip
			expect(exists).toBeFalsy()
			exists = Fs.existsSync testText
			expect(exists).toBeTruthy()
			Fs.remove testText
			done()

	it "can execute zipAndDeleteFiles", (done) ->
		Q.nfcall(Fs.copy, txtSource1, txt1)
		.then () ->
			Q.nfcall(Fs.copy, txtSource2, txt2)
		.then () ->
			Q.nfcall(Fs.copy, txtSource3, txt3)
		.then () ->
			Zipper.zipAndDeleteFiles([txt1, txt2, txt3], sourceZippedFiles)
		.then () ->
			exists = Fs.existsSync sourceZippedFiles
			expect(exists).toBeTruthy()
			exists = Fs.existsSync txt1
			expect(exists).toBeFalsy()
			exists = Fs.existsSync txt2
			expect(exists).toBeFalsy()
			exists = Fs.existsSync txt3
			expect(exists).toBeFalsy()
			Fs.remove sourceZippedFiles
		.done () ->
			done()