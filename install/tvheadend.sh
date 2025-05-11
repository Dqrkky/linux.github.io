curl -fsSL https://tvheadend.org/pgp/tvheadend.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tvheadend.gpg
echo "deb https://apt.tvheadend.org/stable/ubuntu/ plucky main" | sudo tee /etc/apt/sources.list.d/tvheadend.list
curl https://dqrkky.github.io/linux/update.sh | bash
sudo apt-get install tvheadend
