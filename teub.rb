require 'socket'
require 'timeout'

# connect to server

sock = begin
           TCPSocket.open( 'localhost', 2626 )
       rescue StandardError, RuntimeError => ex
           raise "cannot connect to server: #{ex}"
       end

# send sample messages:

puts "sending one-way message"
sock.write( "puts This is a one-way message\r\n" )
sleep( 2 )

puts "sending a request that should be answered"
sock.write( "echo This message should be echoed\r\n" )
response = begin
               Timeout::timeout( 1 ) { sock.gets( "\r\n" ).chomp( "\r\n" ) }
           rescue StandardError, RuntimeError => ex
               raise "no response from server: #{ex}"
           end
puts "received response: '#{response}'"
sleep( 2 )

puts "sending a goodbye message"
sock.write( "puts bye\r\n" )
sock.close