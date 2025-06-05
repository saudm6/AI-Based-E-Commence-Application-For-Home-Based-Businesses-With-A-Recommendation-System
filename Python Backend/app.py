from flask import Flask, request, jsonify
import pandas as pd

app = Flask(__name__)
# Load CSV 
df = pd.read_csv("ai_chatbot_1.csv")

# Search products route
@app.route("/search", methods=["POST"])
def search_products():
    # User input
    user_input = request.json
    # Get the filter and limit
    flt   = user_input.get("filter", "")
    limit = user_input.get("limit", 10)

    # Keyword search on title + description
    output = (
      df["title"].str.contains(flt, case=False, na=False) |
      df["description"].str.contains(flt, case=False, na=False)
    )
    results = df[output]

    # Results
    out = results.head(limit).to_dict(orient="records")
    return jsonify(out)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
