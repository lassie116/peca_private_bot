# -*- coding: utf-8 -*-
require 'pit'
require 'twitter'
require 'open-uri'
require 'logger'

UpdateInterval = 10
YPList = './yplist.txt'
FAVList = './favlist.txt'
Filter = './filter.txt'
NowPlaying = './now_playing'
LogFile = './log'

class PeCaPB
  def initialize
    config = Pit.get("peca_pb",:requere=>{
                       "ckey" => "Consumer key",
                       "csecret" => "Consumer secret",
                       "token" => "OAuth token",
                       "secret" => "OAuth token secret"
                     })

    Twitter.configure do |cnf|
      cnf.consumer_key = config['ckey']
      cnf.consumer_secret = config['csecret']
      cnf.oauth_token = config['token']
      cnf.oauth_token_secret = config['secret']
    end
    
    @log = Logger.new(LogFile)
    @log.level = Logger::INFO

    @now_playing = load_list(NowPlaying)
  end

  def post(str)
    Twitter.update(str.gsub(/@/,'＠'))
  end
    
  def load_yp
    yp = {}
    File.read(YPList).split("\n").each do |line|
      next if line == ''
      name,url = line.split(",")
      yp[name] = url
    end
    yp
  end

  def load_list(path)
    if File.exist?(path)
      File.read(path).split("\n").map {|e| e.chomp} - [""]
    else
      []
    end
  end

  def get_ch_info(name,url)
    index_txt = open(url).read
    @log.info("loading #{name}")
    ret = {}
    index_txt.split("\n").each do |line|
      l = line.split("<>").map {|e| e.chomp}
      ret[l.first] = l
    end
    ret
  end

  def get_all_ch_info(yplist)
    ch_info = {}
    yplist.each do |yp_name,url|
      ch_info.merge!(get_ch_info(yp_name,url))
    end
    ch_info
  end

  def select?(name,info,favlist,filter)
    if favlist.include?(name)
      @log.info "fav:[#{name}]"
      true
    else
      search_target = info[0]+info[4]+info[5]+info[17]
      filter.each do |word|
        if search_target =~ /#{word}/
          @log.info "hit:[#{word}] #{search_target}"
          return true 
        end
      end
      false
    end
  end
  
  def w(flag) 
    (flag && flag != "") ? (yield flag) : ""
  end

  def info_to_s(info)
    name = info[0]
    tag = w(info[4]) {|e| "[#{e}]"}
    comment = w(info[17]) {|e| "/#{e}"}
    detail = info[5]
    "#{name} #{tag}#{detail}#{comment}"
  end

  def step
    yplist = load_yp
    all_ch = get_all_ch_info(yplist)

    favlist = load_list(FAVList)
    filter = load_list(Filter)

    fav_ch = {}
    all_ch.each do |name,info|
      fav_ch[name] = info if select?(name,info,favlist,filter)
    end

    start_ch = fav_ch.keys - @now_playing
    end_ch = @now_playing - fav_ch.keys

    start_list = start_ch.map {|name| info_to_s(fav_ch[name])}
    end_list = end_ch.map {|name| "#{name}が終了/詳細を変更しました" }
    @now_playing = fav_ch.keys

    open(NowPlaying,"w") do |f|
      @now_playing.each do |n|
        f.puts n
      end
    end

    post_list = start_list + end_list
    post_list.each do |str|
      begin
        @log.info "post > #{str}"
        post(str)
      rescue Twitter::Forbidden
        @log.error("twitter post failed?")
      end
      sleep 30
    end
  end

  def start
    loop do
      step
      sleep(UpdateInterval * 60)
      # sleep 60
    end
  end
end

if __FILE__ == $0
  PeCaPB.new.start
end
