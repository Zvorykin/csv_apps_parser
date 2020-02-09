// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'

import { Container, Form, Col } from 'react-bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css'


class MarkdownParser extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      markdown: '',
      html: '',
    }

    this.onMarkdownChange = this.onMarkdownChange.bind(this)
  }

  async onMarkdownChange(event) {
    this.setState({ markdown: event.target.value })

    const result = await fetch(`${ window.origin }/parse`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        markdown: event.target.value,
      }),
    }).then(res => res.json())

    this.setState({ ...this.state, html: result.html })
  }

  render() {
    return (
      <Container className="mt-3">
        <Form>
          <Form.Row>
            <Form.Group as={ Col }>
              <Form.Label>Markdown</Form.Label>
              <Form.Control as="textarea" rows="15" value={ this.state.markdown }
                            onChange={ this.onMarkdownChange }/>
            </Form.Group>
            <Form.Group as={ Col }>
              <Form.Label>HTML</Form.Label>
              <Form.Control as="textarea" rows="15" value={ this.state.html } disabled/>
            </Form.Group>
          </Form.Row>
        </Form>
      </Container>
    )
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <MarkdownParser/>,
    document.body.appendChild(document.createElement('div')),
  )
})
