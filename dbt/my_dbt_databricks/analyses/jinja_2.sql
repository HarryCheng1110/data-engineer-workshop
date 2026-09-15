{%- set books = ["The Great Gatsby", "To Kill a Mockingbird", "1984", "Pride and Prejudice", "The Catcher in the Rye"] -%}

{% for book in books %}
    {% if book.split(' ')|length > 3 %}
        {{ book }}
    {% else %}
        It has less than or equal to 3 words: {{ book }}
    {% endif %}
{% endfor %}