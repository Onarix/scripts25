const WIDTH = 800;
const LENGTH = 600;
const TILE_SIZE = 32;
let facing_right = true;

class MainScene extends Phaser.Scene {
    constructor() {
        super('MainScene');
    }

    preload() {
        this.load.image('tiles', 'assets/tileset.png');
        this.load.spritesheet('player', 'assets/player.png', { frameWidth: TILE_SIZE / 2, frameHeight: TILE_SIZE });
        this.load.image('flag', 'assets/flag.png');
    }

    create() {
        // Holes
        let holes = [9,10,11];

        // Platform
        this.platforms = this.physics.add.staticGroup();
        for(let i = 0; i < WIDTH; i += TILE_SIZE) {
            if(!holes.includes(i/TILE_SIZE)) 
                this.platforms.create(i, LENGTH - TILE_SIZE, 'tiles').refreshBody();
        }

        // Obstacles
        let obstacles = [
            4, 15, 
            5, 15,
            15, 17,
            16, 17,
            17, 17,
            16, 16,
            17, 16,
            17, 15,
        ];
        for(let i = 0; i < obstacles.length; i += 2) 
            this.platforms.create(obstacles[i] * TILE_SIZE, obstacles[i + 1] * TILE_SIZE, 'tiles').refreshBody();

        // Player
        this.player = this.physics.add.sprite(32, 450, 'player').setScale(1.2);
        this.player.setBounce(0.2);
        this.player.setCollideWorldBounds(false);

        // Flag
        this.flag = this.physics.add.staticGroup();
        this.flag.create(WIDTH - TILE_SIZE * 2, LENGTH - TILE_SIZE * 4 + 30, 'flag').setScale(2).refreshBody();
        this.physics.add.overlap(this.player, this.flag, () => {
            this.scene.restart();
        }, null, this);

        // Gravity/Collision
        this.physics.add.collider(this.player, this.platforms);

        // Keys
        this.cursors = this.input.keyboard.createCursorKeys();
    }

    update() {
        this.player.setOrigin(0,0);

        if (this.cursors.left.isDown) {
            if(facing_right) {
                this.player.flipX = facing_right;
                facing_right = false;
            }
            this.player.setVelocityX(-160);
        } else if (this.cursors.right.isDown) {
            if(!facing_right) {
                this.player.flipX = facing_right;
                facing_right = true;
            }
            this.player.setVelocityX(160);
        } else {
            this.player.setVelocityX(0);
        }

        this.input.keyboard.on('keydown-SPACE', () => {
            if (!this.player.body.onFloor()) { return; }
            this.player.setVelocityY(-330);
        })

        // Player falls in hole == restart
        if (this.player.y > 600) {
            this.scene.restart();
        }
    }
}

const config = {
    type: Phaser.AUTO,
    width: WIDTH,
    height: LENGTH,
    physics: {
        default: 'arcade',
        arcade: {
            gravity: { y: 500 },
            debug: false
        }
    },
    backgroundColor: '#102330',
    scene: MainScene
};

const game = new Phaser.Game(config);
