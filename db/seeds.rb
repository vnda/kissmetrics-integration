# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Store.create!([
  {
    domain: 'www.retex.com.br',
    user: '45050f1d2cbf2d40ef0fc23b836e2b24',
    pass: 'cea766ca3d1ca83686ccb5901a89aa2a',
    km_api_key: '5c3cd05a46e87db20c1ea99b8cb734ec20e5c2b8'
  },
  {
    domain: 'www.bodystore.com.br',
    user: '687bd25d54f49b9aa484',
    pass: '55428634a0bba0b90c58',
    km_api_key: '0a66fa149dc138339ac0dc4cc5c1680246b16fcb'
  },
])