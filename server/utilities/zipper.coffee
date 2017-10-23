AdmZip = require "adm-zip"
FS = require 'fs-extra'
Logger = require './logger'
Q = require "q"

class Zipper
	unzipAndDelete: (zipPath, targetFolder) ->
		zip = new AdmZip zipPath
		zip.extractAllTo targetFolder, true
		Q.nfcall(FS.remove, zipPath)
		.catch (err) ->
			# log the error but continue
			# not a big deal if we can't delete old zip from temp folder
			Logger.error "could not delete zip file at #{zipPath}"
			Logger.error err

	# takes in a list of file paths, zips them up, and deletes the original files
	zipAndDeleteFiles: (filePaths, zipPath) ->
		zipper = new AdmZip()
		for path in filePaths
			zipper.addLocalFile path
		zipper.writeZip zipPath
		promises = []
		for path in filePaths
			promises.push(Q.nfcall(FS.unlink, path)
			.catch (err) ->
				# log the error but continue
				# not a big deal if we can't delete old txt file
				Logger.error "Could not delete txt file of game at #{matchPath}.txt"
				Logger.error err)
		Q.allSettled(promises)


module.exports = new Zipper()