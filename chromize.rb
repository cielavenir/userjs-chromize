#!/usr/bin/ruby
#coding:utf-8
# Chromize: Enable user.js on Chrome even after hard-blocking.
# (C) @cielavenir under Fair License.

require 'json'

module Chromize
	# VERSION string
	VERSION='0.0.0.1'

	# Emit manifest.json for given fname (user.js).
	def self.chromize(fname,options_for_json={})
		options_for_json={
			:indent=>"\t",
			:space=>' ',
			:object_nl=>"\n",
			:array_nl=>"\n"
		}.merge(options_for_json)
		manifest={
			'name'=>'chromize',
			'description'=>'chrome extension based on user.js',
			'version'=>'0',
			'manifest_version'=>2,
			'content_scripts'=>[{
				'all_frames'=>true,
				'js'=>[File.basename(fname)],
				'matches'=>[],
			}]
		}
		userjs=false
		File.open(fname){|f|
			while f.gets
				if $_.include?('==UserScript==')
					userjs=true
				else $_.include?('==/UserScript==')
					userjs=false
				end
				if userjs=true && idx=$_.index('@')
					a=$_.chomp[idx+1..-1].split(nil,2)
					if a[0]=='name'
						manifest['name']=a[1]
					elsif a[0]=='description'
						manifest['description']=a[1]
					elsif a[0]=='version'
						manifest['version']=a[1]
					elsif a[0]=='run-at'
						manifest['content_scripts'][0]['run_at']=a[1].gsub('-','_')
					elsif a[0]=='include'
						manifest['content_scripts'][0]['matches'].push(a[1])
					end
				end
			end
		}
		if manifest['content_scripts'][0]['matches'].empty?
			manifest['content_scripts'][0]['matches']=['<all_urls>']
		end
		File.open(File.dirname(fname)+'/manifest.json','w'){|f|
			f.puts JSON.generate(manifest,options_for_json)
		}
	end
end

if $0==__FILE__
	ARGV.each{|e|
		Chromize.chromize(e)
	}
end
