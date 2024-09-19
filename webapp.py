from flask import Flask, request, render_template
from smartpi_gpio.gpio import GPIO

app = Flask(__name__)
gpio = GPIO()

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/gpio/<int:pin>/read")
def read_pin(pin):
    try:
        valeur = gpio.read(pin)
        return {"pin": pin, "value": valeur}
    except Exception as e:
        return {"error": str(e)}, 500

@app.route("/gpio/<int:pin>/write", methods=["POST"])
def write_pin(pin):
    try:
        valeur = request.json.get("value")
        gpio.write(pin, int(valeur))
        return {"pin": pin, "status": "written"}
    except Exception as e:
        return {"error": str(e)}, 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
