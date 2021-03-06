require 'forwardable'
module Sshez
  #
  # handles all the ssh commands and updates to the .ssh/config file
  #
  class Exec
    extend Forwardable
    FILE_PATH = File.expand_path('~') + '/.ssh/config'
    PRINTER = PrintingManager.instance
    #
    # to create an instance pass any +Struct+(listener) that handles the following methods
    # *  :argument_error(+Command+)
    # *  :done_with_no_guarantee
    # *  :permission_error
    # *  :finished_successfully
    #
    attr_reader :listener

    def_delegators :@listener, :argument_error
    def_delegators :@listener, :done_with_no_guarantee

    #
    # Must have the methods mentioned above
    #
    def initialize(listener)
      @listener = listener
    end

    #
    # Starts the execution of the +Command+ parsed with its options
    #
    def start_exec(command, options)
      all_args = command.args
      all_args << options
      self.send(command.name, *all_args)
    end

    private
    #
    # connects to host using alias
    #
    def connect(alias_name, options)
      file = File.open(FILE_PATH, 'r')
      servers = all_hosts_in(file)
      if servers.include?alias_name
        PRINTER.verbose_print "Connecting to #{alias_name}"
        exec "ssh #{alias_name}"
      else
        PRINTER.print "Could not find host `#{alias_name}`"
      end
    end

    #
    # append an alias for the given user@host with the options passed
    #
    def add(alias_name, user, host, options)
      begin
        PRINTER.verbose_print "Adding\n"
        config_append = form(alias_name, user, host, options)
        PRINTER.verbose_print config_append
        unless options.test
          file = File.open(FILE_PATH, 'a+')
          file.write(config_append)
          file.close

          # causes a bug in fedore if permission was not updated to 0600
          File.chmod(0600, FILE_PATH)
          # system "chmod 600 #{FILE_PATH}"
        end
      rescue
        return permission_error
      end
      PRINTER.verbose_print "to #{FILE_PATH}"
      PRINTER.print "Successfully added `#{alias_name}` as an alias for `#{user}@#{host}`"
      PRINTER.print "Try sshez connect #{alias_name}"

      finish_exec
    end # add(alias_name, user, host, options)

    #
    # returns the text that will be added to the config file
    #
    def form(alias_name, user, host, options)
      retuned = "\n"
      retuned += "Host #{alias_name}\n"
      retuned += "  HostName #{host}\n"
      retuned += "  User #{user}\n"

      options.file_content.each_pair do |key, value|
        retuned += value
      end
      retuned

    end # form(alias_name, user, host, options)

    #
    # removes an alias from the config file (all its occurrences will be removed too)
    #
    def remove(alias_name, options)
      file = File.open(FILE_PATH, 'r')
      servers = all_hosts_in(file)
      if servers.include?alias_name
        new_file = File.open(FILE_PATH + 'temp', 'w')
        remove_alias_name(alias_name, file, new_file)

        File.delete(FILE_PATH)
        File.rename(FILE_PATH + 'temp', FILE_PATH)
        # Causes a bug in fedore if permission was not updated to 0600
        File.chmod(0600, FILE_PATH)
        PRINTER.print "`#{alias_name}` was successfully removed from your hosts"
      else
        PRINTER.print "Could not find host `#{alias_name}`"
      end
      finish_exec
    end # remove(alias_name, options)

    #
    # copies the content of the file to the new file without
    # the sections concerning the alias_name
    #
    def remove_alias_name(alias_name, file, new_file)
      started_removing = false
      file.each do |line|
        started_removing ||= line.include?("Host #{alias_name}")
        if started_removing
          # I will never stop till I find another host that is not the one I'm removing
          stop_removing = (started_removing && line.include?('Host ') && !(line =~ /\b#{alias_name}\b/))
          PRINTER.verbose_print line unless stop_removing
          if stop_removing && started_removing
            new_file.write(line)
          end
          started_removing = !stop_removing
        else
          # Everything else should be transfered safely to the other file
          new_file.write(line)
        end
      end
      file.close
      new_file.close
    end #remove_alias_name(alias_name, file, new_file)

    #
    # lists the aliases available in the config file
    #
    def list(options)
      file = File.open(FILE_PATH, 'a+')
      servers = all_hosts_in(file)
      file.close
      if servers.empty?
        PRINTER.print 'No aliases added'
      else
        PRINTER.print 'Listing aliases:'
        servers.each{|x| PRINTER.print "\t- #{x}"}
      end
      finish_exec
    end # list(options)

    def reset(options)
      resp = PRINTER.prompt 'Are you sure you want to remove all aliases? [Y/n]'
      if resp.match(/y/i)
        file = File.open(FILE_PATH, "w")
        file.close
        PRINTER.print 'You have successfully reset your ssh config file.'
      end
    end

    #
    # Returns all the alias names of in the file
    #
    def all_hosts_in(file)
      servers = []
      file.each do |line|
        if line.include?('Host ')
          servers << line.sub('Host ', '').strip
        end
      end
      servers
    end

    #
    # Raises a permission error to the listener
    #
    def permission_error
      listener.permission_error
    end

    #
    # finished editing the file successfully
    #
    def finish_exec
      listener.finished_successfully
    end
    # private
  end # class FileManager
end
