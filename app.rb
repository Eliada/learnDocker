require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
set :bind, '0.0.0.0'

DB_HOST = ENV['DB_HOST'] || 'localhost'

Rom = ROM.container(
  :sql,
  "postgres://#{DB_HOST}:5432/demo",
  username: 'user',
  password: 'pass'
) do |config|
  config.relation(:requests) do
    schema(infer: true)
    auto_struct true
  end
end

requests = Rom.relations[:requests]

get '/' do
  moment = {
    requested_at: Time.now,
    ip: IPSocket.getaddress(Socket.gethostname),
    host: Socket.gethostname,
    path: '/'
  }

  requests.changeset(:create, moment).commit
  log = <<~HTML
  <head>
      <style>
      table {
        font-family: arial, sans-serif;
        border-collapse: collapse;
        width: 100%;
      }

      td, th {
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
      }

      tr:nth-child(even) {
        background-color: #dddddd;
      }
      </style>
      </head>
  HTML
  log << '<table>'
  log << '<tr> <th> path </th> <th> at </th> <th> host </th> <th> ip </th> </tr>'
  requests.order { id.desc }.limit(25).map do |req|
    log << "
      <tr>
      <td> #{req[:path]} </td>
      <td> #{req[:requested_at]} </td>
      <td> #{req[:host]} </td>
      <td> #{req[:ip]} </td>
      </tr>
    "
  end
  log << '</table>'
  log
end
