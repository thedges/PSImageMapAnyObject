import {LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {loadScript} from 'lightning/platformResourceLoader';
import getAreas from '@salesforce/apex/PSImageMapAnyObjectController.getAreas';
import IMAGE_RESIZER from '@salesforce/resourceUrl/PSImageMapResizer';

export default class PsImageMapAnyObject
  extends NavigationMixin (LightningElement) {
  @api imageName;
  @api sobjectName;
  @api titleField;
  @api idField;
  @api shapeField;
  @api coordsField;
  @api detailsField;
  @api detailsPosition;
  @api whereClause;

  @track areas;

  @track config;
  @track areaDetails;
  resource;

  @api configId;
  @api lookupField;
  @api hoverField;

  get resourceURL () {
    // /resource/1559329958000/LakeSiteMap
    //this. resource = 'SFloorML';
    if (this.imageName.startsWith ('/resource')) {
      return this.imageName;
    } else {
      return '/resource/' + this.imageName;
    }
  }

  connectedCallback () {
    console.log ('connectedCallback');

    getAreas ({
      sobjectName: this.sobjectName,
      titleField: this.titleField,
      idField: this.idField,
      shapeField: this.shapeField,
      coordsField: this.coordsField,
      detailsField: this.detailsField,
      whereClause: this.whereClause,
    })
      .then (result => {
        console.log ('result= ' + result);
        this.areas = JSON.parse (result);

        loadScript (this, IMAGE_RESIZER).then (() => {
          var matches = this.template.querySelectorAll ('.site-map');

          try {
            imageMapResize (this.template.querySelector ('.site-map'), this);
          } catch (ex) {
            console.log ('exception=' + JSON.stringify (ex));
            this.handleError(ex);
          }
        });
      })
      .catch (error => {
        console.log ('error=' + JSON.stringify (error));
      });
  }

  handleAreaClick (event) {
    console.log ('handleAreaClick...');

    const targetArea = this.areas.filter (
      area => area.title === event.target.alt
    );

    if (targetArea.length === 1) {
      this[NavigationMixin.Navigate] ({
        type: 'standard__recordPage',
        attributes: {
          recordId: targetArea[0].id,
          actionName: 'view',
        },
        //objectApiName: 'namespace__ObjectName',
      });
    }
  }

  handleMouseOver (event) {
    console.log ('handleMouseOver...');

    var img = this.template.querySelector ('.site-image');

    this.setDetailsPostion (
      this.getDetailsPosition (this.getEventQuadrant (img, event))
    );

    const targetArea = this.areas.filter (
      area => area.title === event.target.alt
    );

    if (targetArea.length === 1) {
      //this.areaDetails = targetArea[0].details;
      var el = this.template.querySelector ('.area-details');
      el.innerHTML = targetArea[0].details;
      el.classList.remove ('hide');
    }
  }

  getEventQuadrant (el, ev) {
    var rect = el.getBoundingClientRect ();

    var x = ev.clientX - rect.left; //x position within the element.
    var y = ev.clientY - rect.top; //y position within the element.

    if (x < el.clientWidth / 2 && y < el.clientHeight / 2) {
      return 1;
    } else if (x >= el.clientWidth / 2 && y < el.clientHeight / 2) {
      return 2;
    } else if (x >= el.clientWidth / 2 && y >= el.clientHeight / 2) {
      return 3;
    } else {
      return 4;
    }
  }

  setDetailsPostion (cl) {
    var el = this.template.querySelector ('.area-details');
    el.classList.remove ('top-left');
    el.classList.remove ('top-right');
    el.classList.remove ('bottom-left');
    el.classList.remove ('bottom-right');

    el.classList.add (cl);
  }

  getDetailsPosition (quadrant) {
    var cl = 'bottom-left';

    switch (quadrant) {
      case 1:
        cl = 'top-right';
        break;
      case 2:
        cl = 'top-left';
        break;
      case 3:
        cl = 'bottom-left';
        break;
      default:
        cl = 'bottom-right';
    }

    switch (this.detailsPosition) {
      case 'Top-Left':
        cl = 'top-left';
        break;
      case 'Top-Right':
        cl = 'top-right';
        break;
      case 'Bottom-Left':
        cl = 'bottom-left';
        break;
      case 'Bottom-Right':
        cl = 'bottom-right';
        break;
    }

    return cl;
  }

  handleMouseOut (event) {
    console.log ('handleMouseOut...');
    var el = this.template.querySelector ('.area-details');
    el.innerHTML = '';
    el.classList.add ('hide');
  }

  handleError (err) {
    console.log ('error=' + err);
    console.log ('type=' + typeof err);

    this.showSpinner = false;

    const event = new ShowToastEvent ({
      title: err.statusText,
      message: err.body.message,
      variant: 'error',
      mode: 'pester',
    });
    this.dispatchEvent (event);
  }
}