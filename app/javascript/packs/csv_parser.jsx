// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'

import { Container, Form, Col, Button, ButtonToolbar, Table } from 'react-bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css'

import bsCustomFileInput from 'bs-custom-file-input'


class CsvParser extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      file: '',
      apps: '',
    }

    this.onFileChange = this.onFileChange.bind(this)
    this.onUploadClick = this.onUploadClick.bind(this)
  }

  onFileChange(event) {
    this.setState({ file: event.target.files[0] })
  }

  async onUploadClick() {
    const body = new FormData()
    body.append('file', this.state.file)

    const result = await fetch(`${ window.origin }/parse`, {
      method: 'POST',
      body,
    }).then(res => res.json())

    console.log(result)

    this.setState({ ...this.state, apps: result.apps })
  }

  render() {
    return (
      <Container className="mt-3">
        <Form>
          <Form.Row>
            <Form.Group as={ Col } className="col-3">
              <Form.Label>CSV</Form.Label>
              <div className="custom-file">
                <input id="inputGroupFile01" type="file" className="custom-file-input" onChange={ this.onFileChange }/>
                <label className="custom-file-label" htmlFor="inputGroupFile01">Choose file</label>
              </div>
              <ButtonToolbar className="mt-3 justify-content-end">
                <Button variant="primary" onClick={ this.onUploadClick }>Upload</Button>
              </ButtonToolbar>
            </Form.Group>

            <Form.Group as={ Col } className="col-9">
              <Form.Label>Apps</Form.Label>
              <Table striped bordered hover size="sm">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Id</th>
                    <th>Store</th>
                    <th>Link</th>
                  </tr>
                </thead>
                <tbody>
                    {(this.state.apps || []).map(({id, store, link}, index) => {
                      return <tr key={id}>
                        <td>{index + 1}</td>
                        <td>{id}</td>
                        <td>{store}</td>
                        <td>{link}</td>
                      </tr>
                    })}
                </tbody>
              </Table>
            </Form.Group>
          </Form.Row>
        </Form>
      </Container>
    )
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <CsvParser/>,
    document.body.appendChild(document.createElement('div')),
  )

  bsCustomFileInput.init()
})
