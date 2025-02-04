variable "ssh_pub_key" {
  type = string
  nullable = false
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6OgyxYZyBz0EgnEpxJoaB+TmkBtAT8+zn1nc/VUeHPSzOWF+i78RIGS6n+dwRvwndmbDKR1lSmYFba4XsJwArpSduQbBRXT+Q503l/gFPjO3CBUvdK0jmDqXu+UXW+KPbn/uGNBBLmuRbeuC5T47+xPGalGaf5cVfbVuVy5J1PnZemSdjZHSDzlOKmZxSbqDTXzPXvwO929fq6j0x1tTVTYl6BEzE9chhloKeUCmq3F73yGDtZhmr4iOYSkQMIjJC1wm9dQZBasdsvb8KOFnAr2jk6QzAI8QnhTH8NG0rR2OQFVLOJhwX7rsi/DoTRZ0zyvaNxzS3F9ka+h0rxYOsEpCcXE6Rst218JPbyY4F6XzcEeaO5Fw5dez146y7NHo2DKQDBAjftYn9mVbeTXj5SCM2PeXI3ps9pV86/+pNq3w3t9yQnWiJG027kFBGdL5rZbUUGyi2NHR+BKO5lxbkCjJnkH+xSWRd7VWdni6loppIlZlNUX0QEqvCuIKLbfGr6G6ueWaiM9bO0cmJ4sU3O8HUDrWaO+VQ1T/iLG094NmtHDj8A/I3NGl84X45Xv7BtfX1HReECfA7Gtv7KQt+ynT3hV4ypTFTYTnGwZyp5CS0XI2DYJYqjWGH749DC1EyMGBVagbBNG9Wo7XSv/8JLlOcIkEB1HPWQ+yn7PTsCw== pnishcha@pnishcha-mobl1"
}
variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}
variable "vpc_cidr_block1" {
  type = string
  default = "10.0.1.0/24"
}
variable "vpc_cidr_block2" {
  type = string
  default = "10.0.2.0/24"
}
variable "zone1" {
  type = string
  nullable = false
  default = "us-west-1a"
}
variable "zone2" {
  type = string
  nullable = false
  default = "us-west-1b"
}
variable "instance_type"{
  type = string
  default = "t2.micro"
}

variable "cpu_core_count"{
  type = number
  default = 2
}

variable "region"{
  type = string
  default = "us-west-1"
}

variable "profile"{
  type = string
  default = "default"
}
