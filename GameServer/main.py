# -*- coding: utf-8 -*-

from app import app

def main():
    app().run(8001)

if __name__ == "__main__":
    try:
        main()
    except:
        quit()