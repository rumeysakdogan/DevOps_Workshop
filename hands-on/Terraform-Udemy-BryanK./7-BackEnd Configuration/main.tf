resource "random_string" "random" {
length = 10 
}

output "my_string"{
  value = random_string.random.result
}