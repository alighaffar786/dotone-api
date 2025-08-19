FactoryBot.define do
  sequence :currency do |n|
    23.38 + n
  end

  sequence :description do |n|
    "description is here #{n}"
  end

  sequence :email do |n|
    "email#{n}@email.com"
  end

  sequence :name do |n|
    "name#{n}"
  end

  sequence :url do |n|
    "http://somedomain#{n}.com"
  end

  sequence :username do |n|
    "username#{n}"
  end

  sequence :xn do |n|
    a = "aa".upto("zz").map{ |x| x } + "AA".upto("ZZ").map{ |x| x }
    a[n].present? ? a[n] : n
  end

  sequence :xxn do |n|
    if n.to_s.size == 1
      "xx#{n}"
    elsif n.to_s.size == 2
      "x#{n}"
    else
      "#{n}"
    end
  end
end
