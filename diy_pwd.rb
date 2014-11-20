# -*- coding: utf-8 -*-
require 'digest'

#gen_pwd primary_pwd desc rev :: str -> str -> int -> int
#fmt_pwd gen_pwd rule size retry :: int -> str -> int -> int -> str
#vrf_pwd fmt_pwd rule :: str -> str -> bool
class PassWord
  attr_reader :pwd, :rty
  def initialize pwd, rty
    @pwd, @rty = pwd, rty
  end
end

class MyPwd
  @@rules = {'u' => 'A'..'Z', 'd' => 'a'..'z', 'n' => '0'..'9', 'o' => '#'..'&'}
  def initialize primary_pwd, rule='udn', custom=''
    @primary, @rule, @custom = primary_pwd, rule, custom
    @@rule = rule.split('').map {|x| @@rules[x].to_a }
  end

  def gen_seed desc, rev
    (Digest::SHA1.hexdigest @primary + desc + rev.to_s).to_i(16)
  end

  def lcg seed
    seed * 630360016 % 2147483647
  end

  def gen_pwd seed, size, try
    [*1..size].inject([seed + try]){|n, x| n << (lcg n[-1])}[1..size]
  end

  def fmt_pwd pwd, rule, custom
    rl = rule.flatten + custom.split('')
    pwd.map{|x| rl[x % rl.size] }
  end

  def show desc, rule=false, rev:0, size:10, try:0, custom:@custom
    rl = unless rule then @@rule else rule.split('').map {|x| @@rules[x].to_a } end
    seed = gen_seed desc, rev
    result = nil
    until verify result, rl
      pwd = gen_pwd seed, size, try
      result = fmt_pwd pwd, rl, custom
      try += 1
    end
    PassWord.new result.join, try
  end

  def verify pwd, rule
    return false unless pwd
    rst = rule.map do |r|
      lambda do
        for x in pwd
          return true if r.include? x
        end
        return false
      end[]
    end
    rst.inject{|n, x| n and x }
  end
end