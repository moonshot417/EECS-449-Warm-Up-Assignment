walker hello_world_no_body {
    can return_message with `root entry {
        report {
            "response": "Hello, world!"
        };
    }
}

walker hello_world_with_body {
    has name: str;
    can return_message with `root entry {
        report {
            "response": "Hello, " + self.name + "!"
        };
    }
}


walker add_numbers {
    has num1: int;
    has num2: int;

    can calculate_sum with `root entry {
        sum = self.num1 + self.num2;
        report {
            "response": "The sum of " + str(self.num1) + " and " + str(self.num2) + " is " + str(sum) + "."
        };
    }
}


walker reverse_string {
    has input_str: str;

    can reverse with `root entry {
        reversed_str = self.input_str[::-1];
        report {
            "response": "The reverse of " + self.input_str + " is " + reversed_str + "."
        };
    }
}
