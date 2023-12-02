class Mastermind

    EMPTY_SLOTS = "( ) ( ) ( ) ( )"
    VALID_COLORS = ["r", "g", "b", "y", "w"]
   
    def initialize
      @codemaker = CpuPlayer.new
      @codebreaker = Player.new
      @gameboard = []
      @secret_code = ""
    end
  
    def select_gamemode 
      puts "(1) Player try to guess CPU generated secret code"
      puts "(2) Cpu try to guess Player generated code"
      print "Select a game mode: "
      input = gets.chomp[0]
      input == "1" ? start_player_vs_cpu : start_cpu_vs_player
    end
  
    private
  
    def start_player_vs_cpu
      @secret_code = @codemaker.generate_code
      show_help
      puts EMPTY_SLOTS
      12.times do |index| 
        print "Enter your code attempt: "
        code_attempt = gets.chomp.downcase[0..3]
        feedback = @codemaker.check_attempt(code_attempt, @secret_code)
        update_board(code_attempt, feedback)
        puts @gameboard
        if game_over?(code_attempt, feedback)
            puts "Codebreaker won!"
            break
        elsif index == 11
            puts "Codemaker won! the code was #{@secret_code}"
        end
      end
    end
  
    def start_cpu_vs_player
      @codemaker = Player.new
      @codebreaker = CpuPlayer.new
      @secret_code = @codemaker.generate_code
      code_attempt = ""
      wrong_codes = []
      feedback = ""
      12.times do |index|
        wrong_codes << code_attempt
        code_attempt = @codebreaker.generate_attempt(code_attempt, feedback, wrong_codes)
        feedback = @codemaker.check_attempt(code_attempt, @secret_code)
        update_board(code_attempt, feedback)
        break if game_over?(code_attempt, feedback)
        puts "You won! The CPU didn't find the code" if index == 10
      end
      puts @gameboard 
    end
  
    def game_over?(code_attempt, feedback)
      if feedback == "oooo"
        true
      elsif code_attempt == "exit"
        true
      else
        false
      end
    end
  
    def show_help
      print "\n"'From left to right enter the first letter for each color. Example: rbgy'"\n"+
            'The code is 4 characters long and the possible colors are: r g b y w'"\n"+
            'There isn\'t any repeated color in the secret code '"\n"+
            'Each "o" next to your code means there is one color and placement correct'"\n"+
            'Each "x" next to your code means there is one color correct but with wrong placement'"\n"+
            'The position of every "o" and "x" doesn\'t relate to the code'"\n"+
            '(it doesn\'t specify the slot that is correct or not)'"\n"+
            'Enter "exit" to leave the game '"\n""\n"
    end
  
    def update_board(attempt,feedback)
        attempt = attempt.split("")
        @gameboard << "(#{attempt[0]}) (#{attempt[1]}) (#{attempt[2]}) (#{attempt[3]}) #{feedback}"
    end	
  
    class CpuPlayer
      #Generates random secret code without repeating colors
      def generate_code
        code = ""	
        4.times do |index|
            while code.length != index + 1
              color = VALID_COLORS[rand(5)]
              code += color if !(code.include?(color))
          end
        end
        code
      end
      #Generates random code attempts until it finds the 4 right colors using the feedback
      #(right color and placement "o" and right color wrong placement "x"), 
      #then generates random codes using only those 4 colors without repeating previously used wrong codes
      def generate_attempt(previous_attempt="",feedback="",wrong_codes=[])
        code = ""
        valid = false
        if feedback.length != 4
            4.times do |index|
              while code.length != index + 1
                color = VALID_COLORS[rand(5)]
                code += color if !(code.include?(color))
            end
          end
          code
        elsif feedback.length == 4
            while valid == false
              code = ""
              4.times do |index|
                while code.length != index + 1
                  color = previous_attempt.split("")[rand(4)]
                  code += color if !(code.include?(color))
              end
            end
            valid = true unless wrong_codes.any? {|wrong_code| code == wrong_code}
          end
          code
        end      
      end
      
      def check_attempt(attempt, secret_code)
        feedback = []
        attempt = attempt.split("")
        attempt.each_with_index do |color, index|
          if color == secret_code[index]
            feedback << "o"
          elsif secret_code.include?(color)
            feedback << "x"
          end
        end
        #reverse the feedback so the player can't so easily deduce which color is correctly placed (it's easy anyway)
        feedback.reverse.join("")  
      end
  
    end
  
    class Player < CpuPlayer
  
      def generate_code
        puts "\n""The valid colors are: r g b y w"
        print "Enter a code for the CPU to guess: "
        code = gets.chomp.downcase[0..3] 
        while /[^rgbyw]/.match(code) || code.length < 4
          puts "The valid colors are: r g b y w"
          print "Enter a code for the CPU to guess: "
          code = gets.chomp.downcase[0..3] 
        end
        code
      end
  
    end
  end
  
  my_game = Mastermind.new
  my_game.select_gamemode