#!/usr/bin/env ruby

require 'colorize'

$MAIL_ERROR
$NAME_ERROR
$DIRECTORY = "/root/AdminScripts/log"

def tableHelp()
    puts "FORMATAÇÃO DO ARQUIVO FONTE".red
    puts "EM CADA LINHA LISTE O NOME COMPLETO E O EMAIL DO USUÁRIO".blue

end


def verify(mail, name)

    $NAME_ERROR = false
    $MAIL_ERROR = false

    command1 = "psql -U root -d accounts -c \"SELECT mail FROM accounts WHERE mail = '#{mail}'\"; 2> #{$DIRECTORY}/output"
    data_mail = %x[#{command1}]

    command2 = "psql -U root -d accounts -c \"SELECT id_user FROM accounts WHERE id_user = '#{name}'\"; 2> #{$DIRECTORY}/output"
    data_name = %x[#{command2}]

    mail_formated = data_mail.split(' ')
    name_formated = data_name.split(' ')
    
    $MAIL_ERROR = (mail_formated[2] == mail)
    $NAME_ERROR = (name_formated[2] == name)

    return ($MAIL_ERROR || $NAME_ERROR)

end


def putDB(name, email, account)
    directorylist = "psql -U root -d accounts -c \"INSERT INTO accounts (id_user,mail,account) VALUES ('#{name}','#{email}','#{account}')\"; 2> #{$directory}/output "
    put = %x[#{directorylist}]
end

def error(errorType)
    puts "\n\t\t\t#{errorType}\n".red
    puts "\t./creteUsers.rb source_file.txt".blue
    puts "\tFor more information, type : ./creteUsers.rb - help \n".blue
    exit
end


def userCreated(user_name)
    puts "O usuário #{user_name} foi criado com sucesso!\n".blue
end

def userError(user_name,mail)
    puts "O usuário #{user_name} -  #{mail} não foi criado!\n".red
    
    if($MAIL_ERROR) then
        puts "#{mail} já cadastrado".red
    end

    if($NAME_ERROR) then
        puts "#{user_name} já cadastrado".red
    end


    
end


def loadFile()

    

    begin
        file = File.open(ARGV[0],'r')
    rescue => exception
        error("THIS FILE DOES'T EXIST")
    end

    account_type = "ppgmmc"

    file.each do |line|
        user_data = line.split(' ')


        first_name = user_data[0]

        last_name = user_data[user_data.length-2]

        mail = user_data[user_data.length-1]

        user_name = first_name[0]+last_name
        user_name = user_name.downcase

        if(verify(mail, user_name)) then
            userError(first_name,mail)
        else

            putDB(user_name,mail,account_type)

            puts "./createUser.sh #{user_name} #{mail} 2022-12-31 #{account_type}"

            thr = Thread.new {
                createUser = %x(./createUser.sh #{user_name} #{mail} 2022-12-31 #{account_type} > #{$DIRECTORY}/#{user_name}+".out")
            }
            thr.join

            sucess = %x(su - #{user_name} -c "whoami" )

            exist = sucess <=> user_name

            if(exist == 1) then
                userCreated(user_name)
            else
                userError(user_name,mail)
            end

        end

    end
end


if(ARGV.length > 2) then
    error("MANY ARGUMENTS")
end

if(ARGV.length < 1) then
    error("MISSING ARGUMENTS")
end


if(ARGV[0] == "-") then

    if(ARGV[1] == "help") then
        tableHelp()
        exit
    end
end

loadFile()




